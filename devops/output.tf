output "clients" {
  value = { for client in local.clients : client.hostname => {
    address = "http://${client.dnsname}"
  } }
}
