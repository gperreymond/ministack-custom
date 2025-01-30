#!/bin/bash

# ASDF installation

echo "[INFO] asdf installation"
asdf plugin add nomad
asdf plugin add terraform
asdf plugin add terragrunt
asdf plugin add jq
asdf install

echo ""