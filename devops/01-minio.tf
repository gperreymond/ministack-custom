// --------------------------------------------------------
// THANOS
// --------------------------------------------------------

resource "minio_iam_user" "thanos_stone" {
  name          = "thanos-store"
  force_destroy = true
  update_secret = true
}

resource "minio_s3_bucket" "thanos_stone" {
  bucket        = "thanos-store"
  force_destroy = true
  acl           = "private"
}

resource "minio_iam_service_account" "thanos_stone" {
  target_user = minio_iam_user.thanos_stone.name
}

resource "minio_iam_policy" "thanos_stone" {
  name   = "thanos-store"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"KestraAdmin",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.thanos_stone.arn}", "${minio_s3_bucket.thanos_stone.arn}/*"]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "thanos_stone" {
  user_name   = minio_iam_user.thanos_stone.id
  policy_name = minio_iam_policy.thanos_stone.name
}

resource "null_resource" "minio" {
  depends_on = [
    // thanos-store
    minio_iam_user.thanos_stone,
    minio_iam_service_account.thanos_stone,
    minio_iam_user_policy_attachment.thanos_stone,
    minio_iam_policy.thanos_stone,
    minio_s3_bucket.thanos_stone,
  ]
}
