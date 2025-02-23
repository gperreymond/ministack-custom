#!/bin/bash

mc alias set local http://s3.docker.localhost admin changeme
mc mb local/devops-terraform || true
mc admin accesskey create local/devops-terraform admin --access-key tSad5eW75d49s4uXDlJf --secret-key uE8OKnRU6lWwO1vxpgstklULz5j9KVauZXB5Ohzw || true
