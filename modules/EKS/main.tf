#### IAM Role ####
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

#### 보안 그룹 ####
# EKS 클러스터 보안 그룹
resource "aws_security_group" "eks_sg" {
  name = "eks-sg"
  vpc_id = data.aws_vpc.vpc.id

  # HTTPS 허용
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTP 허용
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API Server와 Kubelet 통신
  ingress {
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS 포트 허용
  ingress {
    from_port = 53
    to_port = 53
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 53
    to_port = 53
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ingress 보안 그룹
resource "aws_security_group" "ingress_sg" {
  name = "eks-ingress-sg"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ArgoCD 노드 그룹 EFS 보안 그룹 생성
resource "aws_security_group" "eks_efs_sg" {
  name = "eks-efs-sg"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = [aws_security_group.eks_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### EKS 클러스터 ####
# 클러스터 생성
resource "aws_eks_cluster" "cluster" {
  name = "eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  
  vpc_config {
    subnet_ids = data.aws_subnets.subnet_ids.ids
    security_group_ids = [aws_security_group.eks_sg.id]
  }
}

# 클러스터 OIDC
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["99def560fe8a73085baa2c640e00157c19547b10"]
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  depends_on = [ aws_eks_cluster.cluster ]
}

# 앱 노드 그룹
resource "aws_launch_template" "app_template" {
  name_prefix = "app-node-group"
  instance_type = "m5.xlarge"
  image_id = "ami-0f62e49579a86b0e4"

  network_interfaces {
    security_groups = [aws_security_group.eks_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-App"
    }
  }
}

resource "aws_eks_node_group" "app_node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "app-node-group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = data.aws_subnets.subnet_ids.ids
  
  scaling_config {
    desired_size = 2
    max_size = 6
    min_size = 2
  }

  launch_template {
    id = aws_launch_template.app_template.id
    version = "$Latest"
  }

  labels = {
    "node" = "app"
  }
}

# 모니터링 노드 그룹
resource "aws_launch_template" "monitoring_template" {
  name_prefix = "monitoring-node-group"
  instance_type = "r5.xlarge"

  network_interfaces {
    security_groups = [aws_security_group.eks_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-Monitoring"
    }
  }
}


resource "aws_eks_node_group" "monitoring_node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "monitoring-node-group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = data.aws_subnets.subnet_ids.ids
  
  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }

  launch_template {
    id = aws_launch_template.monitoring_template.id
    version = "$Latest"
  }

  labels = {
    "node" = "monitoring"
  }
}

# ArgoCD 노드 그룹
resource "aws_launch_template" "argocd_template" {
  name_prefix = "argocd-node-group"
  instance_type = "t3a.xlarge"

  network_interfaces {
    security_groups = [aws_security_group.eks_sg.id,aws_security_group.eks_efs_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-ArgoCD"
    }
  }
}

resource "aws_eks_node_group" "argocd_node_group" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "argocd-node-group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  subnet_ids = data.aws_subnets.subnet_ids.ids
  
  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }

  launch_template {
    id = aws_launch_template.argocd_template.id
    version = "$Latest"
  }

  labels = {
    "node" = "argocd"
  }
}

#### EKS 애드온 ####
# Cluster Autosclaer 역할 생성
resource "aws_iam_role" "eks_autoscaler_iam_role" {
  name = "autoscaler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

# Autoscaler 정책 생성
resource "aws_iam_policy" "autoscaler_policy" {
  name = "EKS_Autoscaler_Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Autoscaler 정책 연결
resource "aws_iam_policy_attachment" "autoscaler_policy" {
  name = "autoscaler-policy"
  roles = [aws_iam_role.eks_autoscaler_iam_role.name]
  policy_arn = aws_iam_policy.autoscaler_policy.arn
}

# AWS Load Balancer Controller 역할 생성
resource "aws_iam_role" "eks_lb_controller" {
  name = "eks-lb-controller"
  assume_role_policy = jsondecode({
        Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${var.region}.amazonaws.com/id/${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://oidc.eks.${var.region}.amazonaws.com/id/", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# AWS Load Balancer Controller 정책 생성
resource "aws_iam_policy" "lb_controller_policy" {
  policy = file("${path.module}/json/lb_controller.json")
}

# AWS Load Balancer Controller 정책 연결 
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

# Cloudwatch Logs 정책 생성
resource "aws_iam_policy" "cloudwatch_agent" {
  name = "cloudwatch-agent-policy"
  policy = file("${path.module}/json/cloudwatch_agent.json")
}

# Cloudwatch Logs 정책 연결
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

# EFS 정책 생성
resource "aws_iam_policy" "efs_policy" {
  name = "efs_policy"
  policy = file("${path.module}/json/efs.json")
}

# EFS 정책 연결
resource "aws_iam_role_policy_attachment" "efs_role" {
  role = aws_iam_role.efs_role.name
  policy_arn = aws_iam_policy.efs_policy.arn
}