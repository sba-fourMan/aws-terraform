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

module "lambda" {
  source = "../modules/lambda"
  JENKINS_TOKEN = var.JENKINS_TOKEN
}