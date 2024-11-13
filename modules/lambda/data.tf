data "aws_lambda_layer_version" "python_requests_layer" {
  layer_name = "python_requests_layer"
}

data "aws_vpc" "dev-vpc" {
  filter {
    name = "tag:Name"
    values = ["Dev-vpc"]
  }
}

data "aws_subnet" "private_subnet" {
  filter {
    name = "tag:Name"
    values = ["Dev-Private3-Subnet"]
  }
}

data "aws_security_group" "lambda" {
  filter {
    name = "tag:Name"
    values = ["Dev-CI-Lambda"]
  }
}