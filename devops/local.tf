locals {
  clients = yamldecode(data.http.kestra_clients.response_body).clients
}
