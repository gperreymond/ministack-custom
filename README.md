# Ministack Custom

An example repository demonstrating how to use Ministack in a fully customized mode. This setup includes preparation scripts for securing and configuring your Nomad and Prometheus environments.

---

## Features

- **Nomad Configuration**: Secure Nomad setup with HTTPS and gossip encryption.
- **Prometheus Integration**: Includes custom `rules` and additional `scrape_configs` for improved monitoring.

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
$ ./scripts/setup.sh
```
This will:
- Install ASDF dependencies.
- Prepare the `.minikube` structure.
- Generate certificates for Nomad.

---

## Usage

### Start the Cluster
To start the cluster, use:
```sh
$ ministack --config cluster.yaml --start
```

### Stop the Cluster
To stop the cluster, use:
```sh
$ ministack --config cluster.yaml --stop
```

### Update Configuration
After modifying files in the `files` directory, reload services using:
```sh
$ ./scripts/reload.sh
```
This script automatically applies updates to the relevant services.

---

## Directory Structure

- **scripts/**: Contains setup and reload scripts.
- **files/**: Configuration files for Nomad and Prometheus.
- **devops/**: Optional works, see `devops/README.md`.
- **netbird/**: Optional works, see `netbird/README.md`.

---

## Some useful links

* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://prometheus.docker.localhost

---

## Contributing

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---
