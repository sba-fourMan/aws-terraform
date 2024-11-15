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

module "lambda" {
  source = "../modules/lambda"
  JENKINS_TOKEN = var.JENKINS_TOKEN
  branch = local.branch
}

module "eventbridge" {
  source = "../modules/eventbridge"
  branch = local.branch
}

module "connect-lambda-eventbridge" {
  source = "../modules/connect-lambda-eventbridge"
  member_event = module.eventbridge.member
  member_lambda = module.lambda.member
  auction_event = module.eventbridge.auction
  auction_lambda = module.lambda.auction
  receipt_event = module.eventbridge.receipt
  receipt_lambda = module.lambda.receipt
  apiGateway_event = module.eventbridge.apiGateway
  apiGateway_lambda = module.lambda.apiGateway
  cert_event = module.eventbridge.cert
  cert_lambda = module.lambda.cert
  config_event = module.eventbridge.config
  config_lambda = module.lambda.config
}