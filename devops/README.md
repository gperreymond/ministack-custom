# DEVOPS

Once the cluster in running, you can now play with this project, the main goal will b to dynamically maintain ketra in single tenant mode.
Everytime, you add or remove a client, it will create a nomad client node, and a full provisionning or kestra in standalone mode.

---

## External services

We simulate external services with `docker-compose.yaml`.
* `minio-single`, for a cloud provider s3 compatible system.
* `kestra-postgres`, for a cloud provider database dedicated to kestra.

```sh
$ cd devops
$ docker compose up -d
```

---

## Terraform configurations

Before applying:
```txt
[x] http://minio-webui.docker.localhost/buckets, create a bucket named `devops-terraform`
[x] http://minio-webui.docker.localhost/access-keys, create `access_key` and `secret_key`, in `read/write`
[x] update the `backend.tf` with your own `access_key` and `secret_key`
```

```sh
$ terraform init
$ terraform apply
```

---

## Some useful links

Global:
* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://prometheus.docker.localhost
* http://minio-webui.docker.localhost (admin/changeme)
* http://pgadmin.docker.localhost (admin@localhost.com/changeme)

Kestra:
* http://kestra.client-1.docker.localhost
* http://kestra.client-2.docker.localhost
* http://kestra.client-3.docker.localhost

---
