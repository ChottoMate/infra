terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}
provider "aws" {
  region = var.region
}

variable "region" { type = string }
variable "env" { type = string }
variable "name" { type = string }
