variable "root_path" {
  type = string
}

#-------------------------------
# PROVIDER: MINIO
#-------------------------------

variable "provider_minio_host" {
  type    = string
  default = "s3.docker.localhost"
}

variable "provider_minio_port" {
  type    = string
  default = "80"
}

variable "provider_minio_username" {
  type    = string
  default = "admin"
}

variable "provider_minio_password" {
  type    = string
  default = "changeme"
}

#-------------------------------
# PROVIDER: POSTGRES
#-------------------------------

variable "provider_postgres_host" {
  type    = string
  default = "rds-postgres.docker.localhost"
}

variable "provider_postgres_port" {
  type    = string
  default = "5432"
}

variable "provider_postgres_username" {
  type    = string
  default = "admin"
}

variable "provider_postgres_password" {
  type    = string
  default = "changeme"
}

variable "traefik_ip" {
  type    = string
  default = "10.1.0.2"
}