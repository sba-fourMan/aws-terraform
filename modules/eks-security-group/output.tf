output "eks_sg" {
  value = aws_security_group.eks_sg
}

output "eks_efs_sg" {
  value = aws_security_group.eks_efs_sg
}

output "ingress_sg" {
  value = aws_security_group.ingress_sg
}