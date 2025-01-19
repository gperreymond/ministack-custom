output "clients" {
  value = { for client in local.clients : client.hostname => {
    address = "http://kestra.${client.dnsname}.docker.localhost"
    }
  }
}
