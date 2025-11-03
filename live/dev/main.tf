locals {
  common_tags = {
    Env       = var.env
    Project   = var.name
    ManagedBy = "Terraform"
  }
}

module "vpc" {
  source   = "../../modules/vpc"
  name     = "${var.env}-${var.name}"
  az_count = 2
  tags     = local.common_tags
}