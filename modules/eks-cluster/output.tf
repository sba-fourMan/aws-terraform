output "eks_cluster" {
  value = aws_eks_cluster.cluster
}

output "eks_oidc" {
  value = aws_iam_openid_connect_provider.eks_oidc
}