data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.up_branch}-vpc"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name = "tag:Name"
    values = ["${var.up_branch}-Public1","${var.up_branch}-Public2"]
  }
}