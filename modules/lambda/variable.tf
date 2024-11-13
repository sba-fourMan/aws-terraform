variable "lambda_role" {
  type = string
  default = "arn:aws:iam::703671902880:role/Lambda_eventbridge"
}

variable "handler" {
  type = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type = string
  default = "python3.12"
}

variable "JENKINS_TOKEN" {}

variable "JENKINS_USER" {
  type = string
  default = "admin"
}

variable "JENKINS_URL" {
  type = string
  default = "http://192.168.56.165:8080/job/"
}

variable "branch" {}
variable "up_branch" {}