terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.2"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
