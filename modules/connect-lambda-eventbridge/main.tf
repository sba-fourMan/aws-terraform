resource "aws_cloudwatch_event_target" "member" {
  rule = var.member_event.name
  arn = var.member_lambda.arn
}

resource "aws_cloudwatch_event_target" "auction" {
  rule = var.auction_event.name
  arn = var.auction_lambda.arn
}

resource "aws_cloudwatch_event_target" "receipt" {
  rule = var.receipt_event.name
  arn = var.receipt_lambda.arn
}

resource "aws_cloudwatch_event_target" "apiGateway" {
  rule = var.apiGateway_event.name
  arn = var.apiGateway_lambda.arn
}

resource "aws_cloudwatch_event_target" "cert" {
  rule = var.cert_event.name
  arn = var.cert_lambda.arn
}

resource "aws_cloudwatch_event_target" "config" {
  rule = var.config_event.name
  arn = var.config_lambda.arn
}

resource "aws_lambda_permission" "member" {
  action = "lambda:InvokeFunction"
  function_name = var.member_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.member_event.arn
}

resource "aws_lambda_permission" "auction" {
  action = "lambda:InvokeFunction"
  function_name = var.auction_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.auction_event.arn
}

resource "aws_lambda_permission" "receipt" {
  action = "lambda:InvokeFunction"
  function_name = var.receipt_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.receipt_event.arn
}

resource "aws_lambda_permission" "apiGateway" {
  action = "lambda:InvokeFunction"
  function_name = var.apiGateway_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.apiGateway_event.arn
}

resource "aws_lambda_permission" "cert" {
  action = "lambda:InvokeFunction"
  function_name = var.cert_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.cert_event.arn
}

resource "aws_lambda_permission" "config" {
  action = "lambda:InvokeFunction"
  function_name = var.config_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = var.config_event.arn
}