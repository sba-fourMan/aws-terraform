# 클러스터 역할
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

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

# EKS 클러스터 정책
resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name = "eks"
  roles = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# VPC Controller 정책
resource "aws_iam_policy_attachment" "eks_vpc_policy" {
  name = "eks-vpc"
  roles = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# 노드 그룹 역할
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 워커 노드 정책
resource "aws_iam_policy_attachment" "eks_worker_policy" {
  name = "eks-worker"
  roles = [aws_iam_role.eks_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# CNI 정책
resource "aws_iam_policy_attachment" "eks_cni_policy" {
  name = "eks-cni"
  roles = [aws_iam_role.eks_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ECR 접근 정책
resource "aws_iam_policy_attachment" "ecr_readonly_policy" {
  name = "ecr-readonly"
  roles = [aws_iam_role.eks_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Cloudwatch Agent 정책
resource "aws_iam_policy_attachment" "cloudwatch_agent_policy" {
  name = "cloudwatch_agent"
  roles = [aws_iam_role.eks_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# SSM 정책
resource "aws_iam_policy_attachment" "ssm_policy" {
  name = "ssm"
  roles = [aws_iam_role.eks_node_group_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}