resource "aws_lambda_function" "member" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-member"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]
  
  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-member-service/build?token=member"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}

resource "aws_lambda_function" "auction" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-auction"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]
  
  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-auction-service/build?token=auction"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}

resource "aws_lambda_function" "apiGateway" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-apiGateway"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]

  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-apiGateway/build?token=apiGateway"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}

resource "aws_lambda_function" "cert" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-cert"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]

  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-cert/build?token=cert"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}

resource "aws_lambda_function" "config" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-config"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]

  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-config/build?token=config"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}

resource "aws_lambda_function" "receipt" {
  filename         = "${path.module}/function/CI.zip"
  function_name    = "${var.branch}-receipt"
  role             = var.lambda_role
  handler          = var.handler
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.python_requests_layer.arn]

  vpc_config {
    security_group_ids = [data.aws_security_group.lambda.id]
    subnet_ids = [data.aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      JENKINS_URL = "${var.JENKINS_URL}${var.branch}-receipt/build?token=receipt"
      JENKINS_TOKEN = var.JENKINS_TOKEN
      JENKINS_USER = var.JENKINS_USER
    }
  }
}