# Ministack Custom

An example repository demonstrating how to use Ministack.

---

## Features

- **Nomad Cluster**: With 3 servers, monitoring client, worker client
- **Monitoring**: Prometheus, complete Thanos implementation, Grafana

```yaml
name: 'europe'
datacenter: 'europe-paris'

plugins:
  # simulate external loadbalancer
  - 'plugins/traefik.yaml'
  # simulate external bucket s3
  - 'plugins/minio-single.yaml'
  # simulate external rds postgres 
  - 'plugins/postgres.yaml'

services:
  nomad:
    enabled: true
    config:
      server:
        bootstrap_expect: 3
        labels:
          - 'traefik.enable=true'
          - 'traefik.http.routers.nomad.rule=Host(`nomad.docker.localhost`)'
          - 'traefik.http.routers.nomad.entrypoints=web'
          - 'traefik.http.services.nomad.loadbalancer.server.port=4646'
    servers:
      - name: 'nomad-server-1'
      - name: 'nomad-server-2'
      - name: 'nomad-server-3'
    clients:
      - name: monitoring-system
        local_volumes:
          - 'prometheus/rules:/mnt/prometheus/rules'
          - 'prometheus/scrape_configs:/mnt/prometheus/scrape_configs'
        docker_volumes:
          - 'prometheus_data'
      - name: worker-global
```

---

## Prerequisites

1. Install [ASDF](https://asdf-vm.com/guide/getting-started.html) by following their guide.
2. Ensure you have the necessary permissions to run shell scripts and install dependencies on your system.

---

## Installation

### 1. Install Ministack
Run the following command to install Ministack:
```sh
$ curl -fsSL https://raw.githubusercontent.com/gperreymond/ministack/main/install | bash
```

### 2. Initial Setup
Prepare your environment by executing the setup script:
```sh
$ ./scripts/install-dependencies.sh
```
This will install all ASDF dependencies:

```
nomad 1.9.6
terraform 1.10.4
terragrunt 0.72.6
jq 1.7.1
mc 2025-02-15T10-36-16Z
```

---

## Usage

### Start the Cluster
To start the cluster, use:
```sh
$ ministack --config configurations/servers/cluster.yaml --start
```

### Stop the Cluster
To stop the cluster, use:
```sh
$ ministack --config configurations/servers/cluster.yaml --stop
```

---

### Terragrunt

After the cluster ip and running, it's time to deploy some jobs.

```sh
# run only once, to create the bucket in minio for terraform states
$ ./scripts/init-minio.sh
# then very classic approach
$ terragrunt init
$ terragrunt apply
```

---

## Directory Structure

- **scripts/**: Contains script.
- **devops/**: Contains terraform infra provisionning.

---

## Some useful links

When ministack has started:
* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://minio-webui.docker.localhost (admin/changeme)

After terraform apply:
* http://prometheus.docker.localhost
* http://thanos-store.docker.localhost
* http://thanos-query.docker.localhost
* http://thanos-query-frontend.docker.localhost


Everytime you add/update/remove rules or scrape configs, do a prometheus reload:
```sh
$ curl -X POST http://prometheus.docker.localhost/-/reload
```

---

## Contributing

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---
