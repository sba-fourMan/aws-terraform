output "eks_iam_role" {
  value = aws_iam_role.eks_cluster_role
}

output "eks_node_group_iam_role" {
  value = aws_iam_role.eks_node_group_role
}