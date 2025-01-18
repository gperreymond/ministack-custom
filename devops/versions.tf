terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
