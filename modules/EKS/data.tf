data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.up_branch}-vpc"]
  }
}