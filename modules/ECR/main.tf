resource "aws_ecr_repository" "member" {
  name = "${var.branch}-member"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "auction" {
  name = "${var.branch}-auction"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "receipt" {
  name = "${var.branch}-receipt"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "apigateway" {
  name = "${var.branch}-apigateway"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "cert" {
  name = "${var.branch}-cert"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "config" {
  name = "${var.branch}-config"
  image_tag_mutability = "MUTABLE"
}