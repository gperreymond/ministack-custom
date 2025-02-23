#!/bin/bash

terraform fmt -recursive
terragrunt hclfmt
