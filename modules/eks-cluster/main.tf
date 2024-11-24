resource "aws_eks_cluster" "cluster" {
  name = "${var.up_branch}-eks-cluster"
  role_arn = var.eks_iam_role.arn
  
  vpc_config {
    subnet_ids = data.aws_subnets.subnet_ids.ids
    security_group_ids = [var.eks_sg.id]
  }
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["99def560fe8a73085baa2c640e00157c19547b10"]
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [ aws_eks_cluster.cluster ]
}