# Cluster Autoscaler 역할 생성
resource "aws_iam_role" "eks_autoscaler_iam_role" {
  name = "autoscaler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${replace(var.eks_cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "autoscaler_policy" {
  name = "autoscaler-policy"
  policy = file("${path.module}/json/cluster_autoscaler.json")
}

resource "aws_iam_policy_attachment" "autoscaler_policy" {
  name = "autoscaler-policy"
  roles = [aws_iam_role.eks_autoscaler_iam_role.name]
  policy_arn = aws_iam_policy.autoscaler_policy.arn
}

# AWS Load Balancer Controller 역할 생성
resource "aws_iam_role" "eks_lb_controller" {
  name = "lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.eks_lb_controller_assume_policy.json
}

resource "aws_iam_policy" "lb_controller_policy" {
  name = "lb-controller-policy"
  policy = file("${path.module}/json/lb_controller.json")
}

resource "aws_iam_policy_attachment" "lb_controller_policy" {
  name = "lb-conroller-policy"
  roles = [aws_iam_role.eks_lb_controller.name]
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

# Cloudwatch Logs 역할 생성
resource "aws_iam_role" "cloudwatch_agent" {
  name = "cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_agent" {
  name = "cloudwatch-agent-policy"
  policy = file("${path.module}/json/cloudwatch_agent.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role = aws_iam_role.cloudwatch_agent.name
  policy_arn = aws_iam_policy.cloudwatch_agent.arn
}

# EFS 역할 생성
resource "aws_iam_role" "efs_role" {
  name = "efs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "efs_policy" {
  name = "efs-policy"
  policy = file("${path.module}/json/efs.json")
}

resource "aws_iam_role_policy_attachment" "efs_role" {
  role = aws_iam_role.efs_role.name
  policy_arn = aws_iam_policy.efs_policy.arn
}

# ArgoCD ECR 권한 역할
resource "aws_iam_role" "argocd" {
  name = "argocd-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "oidc.eks.${var.region}.amazonaws.com/id/${replace(var.eks_cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub" = "system:serviceaccount:argocd:argocd-service-account"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "argocd" {
  name = "argocd-ecr-policy"
  policy = file("${path.module}/json/argocd_ecr.json")
}

resource "aws_iam_role_policy_attachment" "argocd" {
  role = aws_iam_role.argocd.name
  policy_arn = aws_iam_policy.argocd.arn
}

# Secret Manager 역할 생성
resource "aws_iam_role" "external_secrets_role" {
  name = "external-secrets-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${replace(var.eks_cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name = "secrets-manager-policy"
  policy = file("${path.module}/json/external-secrets.json")
}


resource "aws_iam_role_policy_attachment" "external_secrets" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role = aws_iam_role.external_secrets_role.name
}

# EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ebs_policy" {
  name        = "ebs-policy"
  policy      = file("${path.module}/json/ebs_csi_driver.json")
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = aws_iam_policy.ebs_policy.arn
}
