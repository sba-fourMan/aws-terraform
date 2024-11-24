# 앱 노드 그룹
resource "aws_launch_template" "app_template" {
  name_prefix = "app-node-group"
  instance_type = "m5.xlarge"

  network_interfaces {
    security_groups = [var.eks_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-App"
    }
  }
}

resource "aws_eks_node_group" "app_node_group" {
  cluster_name = var.eks_cluster.name
  node_group_name = "app-node-group"
  node_role_arn = var.eks_node_group_iam_role.arn
  subnet_ids = data.aws_subnets.subnet_ids.ids
  
  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }

  launch_template {
    id = aws_launch_template.app_template.id
    version = "$Latest"
  }

  labels = {
    "node" = "app"
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster.name}" = "true"
  }

  lifecycle {
    ignore_changes = [ subnet_ids, scaling_config, launch_template ]
  }
}

# 모니터링 노드 그룹
resource "aws_launch_template" "monitoring_template" {
  name_prefix = "monitoring-node-group"
  instance_type = "r5.xlarge"

  network_interfaces {
    security_groups = [var.eks_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-Monitoring"
    }
  }
}


resource "aws_eks_node_group" "monitoring_node_group" {
  cluster_name = var.eks_cluster.name
  node_group_name = "monitoring-node-group"
  node_role_arn = var.eks_node_group_iam_role.arn
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

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster.name}" = "true"
  }

  lifecycle {
    ignore_changes = [ subnet_ids, scaling_config, launch_template ]
  }
}

# ArgoCD 노드 그룹
resource "aws_launch_template" "argocd_template" {
  name_prefix = "argocd-node-group"
  instance_type = "t3a.xlarge"

  network_interfaces {
    security_groups = [var.eks_sg.id,var.eks_efs_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Test-ArgoCD"
    }
  }
}

resource "aws_eks_node_group" "argocd_node_group" {
  cluster_name = var.eks_cluster.name
  node_group_name = "argocd-node-group"
  node_role_arn = var.eks_node_group_iam_role.arn
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

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster.name}" = "true"
  }

  lifecycle {
    ignore_changes = [ subnet_ids, scaling_config, launch_template ]
  }
}