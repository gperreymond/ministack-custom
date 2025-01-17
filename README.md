# MINISTACK CUSTOM

## Prepare

This project use ASDF
* https://asdf-vm.com/guide/getting-started.html

To install Ministack, follow this step:
```bash
$ curl -fsSL https://raw.githubusercontent.com/gperreymond/ministack/main/install | bash
```

First time, run this script:
```bash
# this will install:
# - asdf dependencies
# - prepare the .minikube structure
# - generate certs for nomad
$ ./scripts/setup.sh
```

## Run

```sh
# start cluster
$ ministack --config cluster.yaml --start
# stop cluster
$ ministack --config cluster.yaml --stop
```

## Documentations

* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-gossip-encryption
* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-enable-tls
