# MINISTACK CUSTOM

This projct is a good start if you want to work on a custom nomad cluster with "ministack".

## Prepare

This project use ASDF
* https://asdf-vm.com/guide/getting-started.html

To install Ministack, follow this step:
```sh
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

## Start / Stop

```sh
# start cluster
$ ministack --config cluster.yaml --start
# stop cluster
$ ministack --config cluster.yaml --stop
```

## Update

Every time you change files in the directory files, you can use th __reload.sh__ script to automatically update the good target services.  
You can play with nomad configuration for leaning, and/or do the same with prometheus.

```sh
$ ./scripts/reload.sh -target [servers|clients|prometheus|all]
```

## URLS

* http://traefik.docker.localhost/
* http://prometheus.docker.localhost/
* http://nomad.docker.localhost/


## Documentations

* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-gossip-encryption
* https://developer.hashicorp.com/nomad/tutorials/transport-security/security-enable-tls
