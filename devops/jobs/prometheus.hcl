job "prometheus" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "prometheus" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 9090
      }
    }

    task "prometheus" {
      driver = "docker"
      user   = "root"

      config {
        image      = "prom/prometheus:${docker_tag}"
        privileged = true
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.enable-remote-write-receiver",
          "--web.enable-lifecycle",
          "--storage.tsdb.retention.time=6h",
          "--storage.tsdb.retention.size=4GB",
          "--storage.tsdb.max-block-duration=2h",
          "--storage.tsdb.min-block-duration=2h",
        ]
        ports = ["http"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "/mnt/prometheus_data:/prometheus",
          "/mnt/prometheus/rules:/etc/prometheus/rules",
          "/mnt/prometheus/scrape_configs:/etc/prometheus/scrape_configs"
        ]
      }

      template {
        data        = <<-EOF
global:
  evaluation_interval: 1m
  scrape_interval: 1m
  scrape_timeout: 10s
rule_files:
  - '/etc/prometheus/rules/*.yaml'
  - '/etc/prometheus/rules/*.yml'
scrape_config_files:
  - '/etc/prometheus/scrape_configs/*.yaml'
  - '/etc/prometheus/scrape_configs/*.yml'
EOF
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        provider = "nomad"
        name     = "prometheus"
        port     = "http"
        tags = [
          "metrics", "monitoring",
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=Host(`prometheus.docker.localhost`)",
          "traefik.http.routers.prometheus.entrypoints=web",
          "traefik.http.services.prometheus.loadbalancer.passhostheader=true",
        ]

        check {
          type     = "http"
          path     = "/-/ready"
          interval = "10s"
          timeout  = "2s"
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
