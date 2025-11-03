terraform {
  backend "s3" {
    bucket       = "tfstate-koguchi-2025"
    key          = "personal-platform/dev/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}