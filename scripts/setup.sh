#!/bin/bash

CLUSTER_NAME="kestra"

# ASDF installation

echo "[INFO] asdf installation"
asdf plugin add nomad
asdf plugin add terraform
asdf plugin add terragrunt
asdf install

# UPDATE files

echo "[INFO] update files"
mkdir -p $HOME/.ministack/$CLUSTER_NAME/prometheus/scrape_configs
mkdir -p $HOME/.ministack/$CLUSTER_NAME/prometheus/rules
mkdir -p $HOME/.ministack/$CLUSTER_NAME/nomad/certs
cp files/nomad/*.hcl $HOME/.ministack/$CLUSTER_NAME/nomad/

# GENERATE certificats

echo "[INFO] generate certificats"
rm *.pem > /dev/null 2>&1
nomad tls ca create
nomad tls cert create -server -region global
nomad tls cert create -client
nomad tls cert create -cli
mv *.pem $HOME/.ministack/$CLUSTER_NAME/nomad/certs
