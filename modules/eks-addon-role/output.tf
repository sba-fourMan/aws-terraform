output "autoscaler_role" {
  value = aws_iam_role.eks_autoscaler_iam_role
}

output "lb_controller_role" {
  value = aws_iam_role.eks_lb_controller
}

output "cloudwatch_role" {
  value = aws_iam_role.cloudwatch_agent
}

output "efs_role" {
  value = aws_iam_role.efs_role
}

output "argocd_role" {
  value = aws_iam_role.argocd
}

output "external_secrets_role" {
  value = aws_iam_role.external_secrets_role
}

output "ebs_role" {
  value = aws_iam_role.ebs_csi_driver_role
}