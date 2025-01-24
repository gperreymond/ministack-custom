# resource "keycloak_realm" "netbird" {
#   enabled              = true
#   realm                = "netbird"
#   display_name         = "Netbird Networking"
#   login_theme          = "base"
#   access_code_lifespan = "1h"
#   internationalization {
#     supported_locales = [
#       "fr",
#       "en",
#       "de",
#       "es"
#     ]
#     default_locale = "fr"
#   }

#   depends_on = [
#     null_resource.postgres,
#   ]
# }

# resource "keycloak_openid_client" "netbird_openid_client" {
#   realm_id              = keycloak_realm.netbird.id
#   client_id             = "netbird"
#   name                  = "netbird"
#   enabled               = true
#   access_type           = "CONFIDENTIAL"
#   implicit_flow_enabled = true
#   valid_redirect_uris = [
#     "*"
#   ]
#   login_theme = "keycloak"

#   depends_on = [
#     keycloak_realm.netbird,
#   ]
# }

resource "nomad_namespace" "netbird_system" {
  name = "netbird-system"

  depends_on = [
    null_resource.postgres,
  ]
}

resource "nomad_variable" "netbird_nomad_agent_configuration" {
  path      = "netbird/configuration/nomad-agent"
  namespace = nomad_namespace.netbird_system.id
  items = {
    agent_setupkey = "2305AF8A-469A-4CC0-B215-85ADE53AEE3B"
  }

  depends_on = [
    nomad_namespace.netbird_system,
  ]
}

# resource "nomad_variable" "netbird_coturn_configuration" {
#   path      = "netbird/configuration/coturn"
#   namespace = nomad_namespace.netbird_system.id
#   items = {
#     user = "self"
#     password = "wSq48K3m0nYbKRuBdZgzRAi+zqMT6TDbEDdELBzehCc"
#   }

#   depends_on = [
#     nomad_namespace.netbird_system,
#   ]
# }

# resource "nomad_variable" "netbird_relay_configuration" {
#   path      = "netbird/configuration/relay"
#   namespace = nomad_namespace.netbird_system.id
#   items = {
#     secret = "Hvgg+2thmK4Lg87nALEHaTKtFRRkMX8QToazl99YF8k"
#   }

#   depends_on = [
#     nomad_namespace.netbird_system,
#   ]
# }

# resource "nomad_variable" "netbird_keycloak_configuration" {
#   path      = "netbird/configuration/keycloak"
#   namespace = nomad_namespace.netbird_system.id
#   items = {
#     netbird_idp_client_id     = keycloak_openid_client.netbird_openid_client.client_id
#     netbird_idp_client_secret = keycloak_openid_client.netbird_openid_client.client_secret
#   }

#   depends_on = [
#     nomad_namespace.netbird_system,
#   ]
# }

resource "nomad_job" "netbird_agent" {
  jobspec = templatefile("${path.module}/jobs/netbird-agent.hcl", {
    destination = nomad_namespace.netbird_system.id,
    docker_tag  = "0.36.3"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.netbird_nomad_agent_configuration,
  ]
}

resource "null_resource" "netbird" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    # keycloak_realm.netbird,
    # keycloak_openid_client.netbird_openid_client,
    nomad_namespace.netbird_system,
    nomad_variable.netbird_nomad_agent_configuration,
    # nomad_variable.netbird_coturn_configuration,
    # nomad_variable.netbird_relay_configuration,
    # nomad_variable.netbird_keycloak_configuration,
    nomad_job.netbird_agent,
  ]
}
