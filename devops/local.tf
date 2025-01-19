locals {
  clients = yamldecode(file("${path.module}/data.yaml")).clients
}
