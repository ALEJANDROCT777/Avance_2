#!/bin/bash
set -e

echo "=== INICIANDO PIPELINE DE SEGURIDAD Y AUDITORÍA ==="
VERDICT=0

echo "[1/3] Deteccion de Secretos..."
if grep -rnE "AKIA[0-9A-Z]{16}|aws_secret_access_key" app/ infra/; then
    echo "❌ FALLO: Se detectaron credenciales en el codigo fuente."
    VERDICT=1
else
    echo "✅ PASO: Cero credenciales expuestas."
fi

echo "[2/3] Auditando Dockerfile..."
if grep -q "USER root" app/Dockerfile || ! grep -q "USER" app/Dockerfile; then
    echo "❌ FALLO: El contenedor se ejecuta como root."
    VERDICT=1
else
    echo "✅ PASO: Dockerfile no ejecuta como root."
fi

echo "[3/3] Verificando proteccion de variables..."
if git status --porcelain 2>/dev/null | grep -q "\.env"; then
    echo "❌ FALLO: El archivo .env esta expuesto."
    VERDICT=1
else
    echo "✅ PASO: El archivo .env esta protegido."
fi

echo "=================================================="
if [ $VERDICT -eq 0 ]; then
    echo "🟢 VEREDICTO FINAL: PERMITIR DESPLIEGUE (PASSED)"
    exit 0
else
    echo "🔴 VEREDICTO FINAL: BLOQUEAR DESPLIEGUE (FAILED)"
    exit 1
fi
