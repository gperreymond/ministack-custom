job "thanos-query" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "thanos-query" {
    count = 1

    network {
      mode = "bridge"
      port "thanos-http" {
        to = 9090
      }
    }

    task "thanos-query" {
      driver = "docker"
      user   = "root"

      config {
        image      = "thanosio/thanos:${thanos_docker_tag}"
        privileged = true
        args = [
          "query",
          "--http-address=0.0.0.0:9090",
          "--endpoint=$${THANOS_SIDECAR_ENDPOINT_GRPC}",
          "--endpoint=$${THANOS_STORE_ENDPOINT_GRPC}",
        ]
        ports = ["thanos-http"]
      }

      template {
        env         = true
        data        = <<-EOF
THANOS_SIDECAR_ENDPOINT_GRPC={{- range nomadService "thanos-sidecar-grpc" }}{{ .Address }}:{{ .Port }}{{- end }}
THANOS_STORE_ENDPOINT_GRPC={{- range nomadService "thanos-store-grpc" }}{{ .Address }}:{{ .Port }}{{- end }}
EOF
        destination = "local/.env"
      }

      resources {
        cpu    = 125
        memory = 128
      }

      service {
        provider = "nomad"
        name     = "thanos-query-http"
        port     = "thanos-http"
        check {
          type     = "http"
          path     = "/-/ready"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
          "metrics", "monitoring",
          "traefik.enable=true",
          "traefik.http.routers.thanos-query.rule=Host(`thanos-query.docker.localhost`)",
          "traefik.http.routers.thanos-query.entrypoints=web",
          "traefik.http.services.thanos-query.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
