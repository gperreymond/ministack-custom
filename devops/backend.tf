terraform {
  backend "s3" {
    bucket = "devops-terraform"
    key    = "terraform.tfstate"
    endpoints = {
      s3 = "http://s3.docker.localhost"
    }
    access_key                  = "tSad5eW75d49s4uXDlJf"                     # Put your own
    secret_key                  = "uE8OKnRU6lWwO1vxpgstklULz5j9KVauZXB5Ohzw" # Put your own
    region                      = "global"                                   # Region validation will be skipped
    skip_credentials_validation = true                                       # Skip AWS related checks and validations
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    # Enable path-style S3 URLs (https://<HOST>/<BUCKET>
    # https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
    use_path_style = true
  }
}
