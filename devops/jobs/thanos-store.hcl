job "thanos-store" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "thanos-store" {
    count = 1

    network {
      mode = "bridge"
      port "thanos-grpc" {
        to = 10901
      }
      port "thanos-http" {
        to = 10902
      }
    }

    task "thanos-store" {
      driver = "docker"
      user   = "root"

      config {
        image      = "thanosio/thanos:${thanos_docker_tag}"
        privileged = true
        args = [
          "store",
          "--data-dir",
          "/data",
          "--objstore.config-file",
          "/etc/bucket.yml",
        ]
        volumes = [
          "/mnt/thanos_store_data:/data",
          "secrets/bucket.yml:/etc/bucket.yml",
        ]
        ports = ["thanos-grpc", "thanos-http"]
        extra_hosts = [
          "s3.docker.localhost:10.1.0.2"
        ]
      }

      template {
        data        = <<-EOF
{{- with nomadVar "monitoring/thanos-store/configuration/bucket" }}
type: s3
config:
  bucket: {{ .bucket }}
  insecure: true
  endpoint: {{ .endpoint }}
  access_key: {{ .access_key }}
  secret_key: {{ .secret_key }}
{{- end }}
EOF
        destination = "secrets/bucket.yml"
      }

      resources {
        cpu    = 250
        memory = 512
      }

      service {
        provider = "nomad"
        name     = "thanos-store-grpc"
        port     = "thanos-grpc"
      }

      service {
        provider = "nomad"
        name     = "thanos-store-http"
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
          "traefik.http.routers.thanos-store.rule=Host(`thanos-store.docker.localhost`)",
          "traefik.http.routers.thanos-store.entrypoints=web",
          "traefik.http.services.thanos-store.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
