# Ministack Custom

An example repository demonstrating how to use Ministack.

---

## Features

- **Nomad Cluster**: With 3 servers and monitoring client
- **Kestra**: A complete terraform examples, adding single tenant kestra clients with nomad at edge

```yaml
name: 'kestra'
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
$ ./scripts/asdf.sh
```
This will:
* Install ASDF dependencies.

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

```sh
$ terragrunt init
$ terragrunt apply
$ ministack --config configurations/clients/kestra-client-1/cluster.yaml --start
$ ministack --config configurations/clients/kestra-client-2/cluster.yaml --start
```

---

## Directory Structure

- **scripts/**: Contains script.
- **devops/**: Contains all works to have dynamic kestra single tenant clients.

---

## Some useful links

* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://minio-webui.docker.localhost (admin/changeme)
* http://kestra.client-1.docker.localhost
* http://kestra.client-2.docker.localhost

Everytime you add/update/remove rules or scrape configs, do a prometheus reload:
```sh
$ curl -X POST http://prometheus.docker.localhost/-/reload
```

---

## Contributing

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---
