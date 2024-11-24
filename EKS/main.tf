locals {
  region = "ap-northeast-2"
}

module "eks_iam_role" {
  source = "../modules/eks-iam"
}

module "eks_security_group" {
  source = "../modules/eks-security-group"
  up_branch = var.up_branch
}

module "eks_cluster" {
  source = "../modules/eks-cluster"
  eks_iam_role = module.eks_iam_role.eks_iam_role
  up_branch = var.up_branch
  eks_sg = module.eks_security_group.eks_sg
}

module "eks_addon_role" {
  source = "../modules/eks-addon-role"
  region = local.region
  eks_oidc = module.eks_cluster.eks_oidc
  eks_cluster = module.eks_cluster.eks_cluster
}

module "eks_node_group" {
  source = "../modules/eks-node-group"
  eks_cluster = module.eks_cluster.eks_cluster
  eks_node_group_iam_role = module.eks_iam_role.eks_node_group_iam_role
  branch = var.up_branch
  eks_efs_sg = module.eks_security_group.eks_efs_sg
  eks_sg = module.eks_security_group.eks_sg
}

module "eks_addon" {
  source = "../modules/eks-addon"
  eks_cluster = module.eks_cluster.eks_cluster
  region = local.region
  autoscaler_role = module.eks_addon_role.autoscaler_role
  lb_controller_role = module.eks_addon_role.lb_controller_role
  cloudwatch_role = module.eks_addon_role.cloudwatch_role
  up_branch = var.up_branch
  ingress_sg = module.eks_security_group.ingress_sg
  password = var.password
  argocd_role = module.eks_addon_role.argocd_role
  external_secrets_role = module.eks_addon_role.external_secrets_role
  ebs_role = module.eks_addon_role.ebs_role
  depends_on = [ module.eks_node_group ]
}