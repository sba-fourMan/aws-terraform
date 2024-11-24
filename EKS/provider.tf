terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "kubernetes" {
  host = module.eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host = module.eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks.token
  }
}