data "aws_iam_policy_document" "eks_lb_controller_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [var.eks_oidc.arn]
    }
    
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test = "StringEquals"
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${replace(var.eks_cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:703671902880:secret:*"
    ]
  }
}