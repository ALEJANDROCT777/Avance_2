import os
import json
import redis
import boto3
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel

app = FastAPI(title="Red Social Breve API")

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
AWS_S3_BUCKET = os.getenv("AWS_S3_BUCKET", "mi-bucket-red-social")

cache = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0, decode_responses=True)

class Post(BaseModel):
    id: str
    usuario: str
    contenido: str

@app.get("/salud")
def health_check():
    try:
        cache.ping()
        return {"estado": "ok", "redis": "conectado", "servicio": "red-social-api"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Error de salud en infraestructura: {str(e)}"
        )

@app.get("/feed")
def obtener_feed():
    feed_cacheado = cache.get("feed_global")
    if feed_cacheado:
        return {"fuente": "cache_redis", "data": json.loads(feed_cacheado)}
    
    feed_db = [
        {"id": "1", "usuario": "ale_torres", "contenido": "¡Hola mundo desde mi app!"},
        {"id": "2", "usuario": "dev_user", "contenido": "Desplegando en AWS Academy"}
    ]
    
    cache.setex("feed_global", 60, json.dumps(feed_db))
    return {"fuente": "base_de_datos_rds", "data": feed_db}

@app.post("/post")
def crear_post(post: Post):
    cache.delete("feed_global")
    return {"mensaje": "Post creado con éxito", "post": post}
