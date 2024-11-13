terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

locals {
  branch = "dev"
}

module "ECR" {
  source = "../modules/ECR"
  branch = local.branch
}