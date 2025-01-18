# DEVOPS

Once the cluster in running, you can now play with terraform, you will have a kestra deployment and managment with terraform.

---

## Run minio

```sh
$ cd devops
$ docker compose up -d
```

---

## Terraform configurations

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

* http://traefik.docker.localhost
* http://nomad.docker.localhost
* http://prometheus.docker.localhost
* http://minio-webui.docker.localhost (admin/changeme)

---