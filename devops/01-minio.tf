resource "minio_iam_user" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  name          = each.value.hostname
  force_destroy = true
  update_secret = true
}

resource "minio_s3_bucket" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  bucket = each.value.hostname
  acl    = "private"
}

resource "minio_iam_service_account" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  target_user = minio_iam_user.kestra[each.value.hostname].name
}

resource "minio_iam_policy" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  name   = each.value.hostname
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"KestraAdmin",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.kestra[each.value.hostname].arn}", "${minio_s3_bucket.kestra[each.value.hostname].arn}/*"]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  user_name   = minio_iam_user.kestra[each.value.hostname].id
  policy_name = minio_iam_policy.kestra[each.value.hostname].name
}

resource "null_resource" "minio" {
  depends_on = [
    // kestra
    minio_iam_user.kestra,
    minio_iam_service_account.kestra,
    minio_iam_user_policy_attachment.kestra,
    minio_iam_policy.kestra,
    minio_s3_bucket.kestra,
  ]
}
