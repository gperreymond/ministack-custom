# Ministack Custom

An example repository demonstrating how to use Ministack in a fully customized mode. This setup includes preparation scripts for securing and configuring your Nomad and Prometheus environments.

---

## Features

- **Nomad Cluster**: With only servers setup

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

## Directory Structure

- **scripts/**: Contains script.
- **devops/**: Contains all works to have dynamic kestra single tenant clients.

---

## Some useful links

* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://prometheus.docker.localhost

---

## Contributing

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---
