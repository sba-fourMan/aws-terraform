data "aws_eks_cluster_auth" "eks" {
  name = module.eks_cluster.eks_cluster.name
}

data "aws_subnets" "subnets" {
  filter {
    name = "tag:Name"
    values = ["${var.up_branch}-Private1","${var.up_branch}-Private2"]
  }
}