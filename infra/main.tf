provider "aws" {
  region = "us-east-1"
}

# 1. Obtener la VPC por defecto de tu cuenta
data "aws_vpc" "default" {
  default = true
}

# 2. Grupo de Seguridad para permitir tráfico a la Base de Datos
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Permitir trafico PostgreSQL interno"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Base de Datos RDS PostgreSQL con el Security Group asignado
resource "aws_db_instance" "database" {
  allocated_storage      = 20
  db_name                = "redsocialdb"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "dbuser"
  password               = "PasswordSeguro2026!"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
