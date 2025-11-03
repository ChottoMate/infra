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

module "api" {
  source             = "../../modules/ecs-service"
  name               = "api"
  env                = var.env
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  cpu                = 512
  memory             = 1024
  container_port     = 8080
  desired_count      = 1
  tags               = local.common_tags
}