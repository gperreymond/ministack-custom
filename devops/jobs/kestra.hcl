job "kestra" {
  region      = "global"
  datacenters = ["*"]
  namespace   = "${destination}"
  type        = "service"
  constraint {
    attribute = "$${attr.unique.hostname}"
    operator  = "="
    value     = "${destination}"
  }
  update {
    stagger      = "30s"
    max_parallel = 1
  }
  group "kestra" {
    network {
      mode = "host"
      port "http" { to = 8080 }
      port "management" { to = 8081 }
    }
    service {
      name     = "${destination}-http"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${destination}.rule=Host(`${dnsname}`)",
        "traefik.http.routers.${destination}.entrypoints=web",
        "traefik.http.services.${destination}.loadbalancer.passhostheader=true",
      ]
    }
    service {
      name     = "${destination}-management"
      provider = "nomad"
      port     = "management"
      tags = [
        "prometheus/scrape=true",
      ]
    }
    task "kestra" {
      driver = "docker"
      user   = "root"
      logs {
        max_files     = 1
        max_file_size = 5
      }
      config {
        image = "kestra/kestra:v${docker_tag}"
        args  = ["server", "standalone"]
        ports = ["http", "management"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "/tmp/kestra-wd:/tmp/kestra-wd",
          "local/application.yml:/app/confs/application.yml:ro",
        ]
      }
      template {
        data        = <<EOH
JVM_ARGS="-Xms1024m -Xmx1024m"
MICRONAUT_CONFIG_FILES="/app/confs/application.yml"
EOH
        destination = "local/config.env"
        env         = true
      }
      template {
        data        = <<-EOF
datasources:
  postgres:
    {{- with nomadVar "kestra/${destination}/configuration/postgres" }}
    url: 'jdbc:postgresql://{{ .host }}:{{ .port }}/{{ .database }}'
    driverClassName: 'org.postgresql.Driver'
    username: '{{ .username }}'
    password: '{{ .password }}'
    {{- end }}
kestra:
  tutorialFlows:
    enabled: false
  queue:
    type: 'postgres'
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  repository:
    type: 'postgres'
  storage:
    type: 'minio'
    minio:
      {{- with nomadVar "kestra/${destination}/configuration/minio" }}
      endpoint: '{{ .endpoint }}'
      port: '{{ .port }}'
      access-key: '{{ .access_key }}'
      secret-key: '{{ .secret_key }}'
      secure: '{{ .secure }}'
      bucket: '{{ .bucket }}'
      {{- end }}
EOF
        destination = "local/application.yml"
      }
      resources {
        cpu    = 350
        memory = 1024
      }
    }
  }
}