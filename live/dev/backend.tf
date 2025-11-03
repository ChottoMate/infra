terraform {
  backend "s3" {
    bucket         = "tfstate-koguchi-2025"
    key            = "personal-platform/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}