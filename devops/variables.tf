variable "provider_minio_host" {
  type    = string
  default = "10.1.0.54"
}

variable "provider_minio_port" {
  type    = string
  default = "9000"
}

variable "provider_minio_username" {
  type    = string
  default = "admin"
}

variable "provider_minio_password" {
  type    = string
  default = "changeme"
}

variable "provider_postgres_host" {
  type    = string
  default = "10.1.0.55"
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

variable "provider_keycloak_username" {
  type    = string
  default = "admin"
}

variable "provider_keycloak_password" {
  type    = string
  default = "changeme"
}
