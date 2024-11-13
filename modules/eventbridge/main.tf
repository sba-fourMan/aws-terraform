resource "aws_cloudwatch_event_rule" "member" {
  name = "${var.branch}-member"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["member"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "auction" {
  name = "${var.branch}-auction"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["auction"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "receipt" {
  name = "${var.branch}-receipt"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["receipt"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "apiGateway" {
  name = "${var.branch}-apiGateway"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["apiGateway"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "cert" {
  name = "${var.branch}-cert"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["cert"]
    }
  })
}

resource "aws_cloudwatch_event_rule" "config" {
  name = "${var.branch}-config"
  role_arn = data.aws_iam_role.role.arn
  event_pattern = jsonencode({
    "source": ["custom.github"],
    "detail-type": ["GitHub Repository Event"],
    "detail": {
      "eventName": ["push"],
      "branch": [var.branch],
      "repository": ["config"]
    }
  })
}