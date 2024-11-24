# Metrics Server 
resource "helm_release" "metrics_server" {
  name = "metrics-server"
  chart = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace = "kube-system"
  
  values = [
    <<EOF
    args:
      - --kubelet-insecure-tls
    EOF
  ]
  
}

# Cluster Autosclaer 서비스 계정 생성
resource "kubernetes_service_account" "autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.autoscaler_role.arn
    }
  }
}
/*
resource "kubernetes_cluster_role" "cluster_autoscaler_role" {
  metadata {
    name = "cluster-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "events"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "watch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler_binding" {
  metadata {
    name = "cluster-autoscaler-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.autoscaler.metadata[0].name
    namespace = kubernetes_service_account.autoscaler.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_autoscaler_role.metadata[0].name
  }
}*/


# Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  name = "cluster-autoscaler"
  chart = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  namespace = "kube-system"
  values = [
    templatefile("${path.module}/values/cluster_autoscaler-values.yaml", {
      cluster_name = var.eks_cluster.name
      region = var.region
      service_account_name = kubernetes_service_account.autoscaler.metadata[0].name
    })
  ]
}

# AWS Load Balancer Controller 서비스 계정 생성
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.lb_controller_role.arn
    }
  }
}

# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"
  chart = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace = "kube-system"
  values = [
    templatefile("${path.module}/values/load_balancer_controller-values.yaml", {
      cluster_name = var.eks_cluster.name
      region = var.region
      vpc_id = data.aws_vpc.vpc.id
      service_account_name = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
    })
  ]
}

# Ingress Controller
resource "helm_release" "ingress_controller" {
  name = "ingress-nginx"
  chart = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace = "kube-system"

  values = [
    templatefile("${path.module}/values/Ingress-values.yaml", {
      ingress_sg = var.ingress_sg.id
      subnets = join(",", data.aws_subnets.subnets.ids)
    })
  ]

  timeout = 600
}

# Cloudwatch Agent ConfigMap 생성
resource "kubernetes_config_map" "cloudwatch_agent_config" {
  metadata {
    name = "cloudwatch-agent-config"
    namespace = "kube-system"
  }
  
  data = {
    "agent-config.json" = <<EOT
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/containers/*.log",
            "log_group_name": "eks-cluster-logs-${var.up_branch}",
            "log_stream_name": "{instance_id}/{pod_name}/{container_name}"
          }
        ]
      }
    }
  }
}
EOT
  }
}

# Cloudwatch Logs 서비스 계정 생성
resource "kubernetes_service_account" "cloudwatch_agent_sa" {
  metadata {
    name = "cloudwatch-agent-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.cloudwatch_role.arn
    }
  }
}

# Cloudwatch Logs
resource "helm_release" "cloudwatch_agent" {
  name       = "cloudwatch-agent"
  chart      = "cloudwatch-agent"
  repository = "https://amazon-eks.s3.us-west-2.amazonaws.com/cloudwatch-agent-helm-chart"
  namespace  = "kube-system"
  values = [
    templatefile("${path.module}/values/cloudwatch_agent-values.yaml", {
      cluster_name = var.eks_cluster.name
      region = var.region
      service_account_name = kubernetes_service_account.cloudwatch_agent_sa.metadata[0].name
      configmap = kubernetes_config_map.cloudwatch_agent_config.metadata[0].name
    })
  ]

  depends_on = [ kubernetes_service_account.cloudwatch_agent_sa ]
}

# NameSpace 생성
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD 서비스 계정 생성
resource "kubernetes_service_account" "argocd_sa" {
  metadata {
    name = "argocd-sa"
    namespace = "argocd"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.argocd_role.arn
    }
  }
}

# ArgoCD
resource "helm_release" "argocd" {
  name       = "argo-cd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values/argocd-values.yaml", {
      password = var.password
      service_account_name = kubernetes_service_account.argocd_sa.metadata[0].name
    })
  ]
}

# ArgoCD Image Updater
resource "helm_release" "argocd_image_updater" {
  name = "argocd-image-updater"
  chart = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values/argocd_image_updater-values.yaml", {
      namespace = kubernetes_namespace.argocd.metadata[0].name
      service_account_name = kubernetes_service_account.argocd_sa.metadata[0].name
    })
  ]
}

# External Secrets 서비스 계정 생성
resource "kubernetes_service_account" "external_secrets_sa" {
  metadata {
    name      = "external-secrets-sa"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.external_secrets_role.arn
    }
  }
}

# External Secrets
resource "helm_release" "external_secrets" {
  name = "external-secrets"
  chart = "external-secrets"
  repository = "https://charts.external-secrets.io"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values/external_secrets-values.yaml", {
      namespace = kubernetes_namespace.argocd.metadata[0].name
      region = var.region
      service_account_name = kubernetes_service_account.metadata[0].name
    })
  ]
}

# Secret Store 생성
resource "kubernetes_manifest" "secret_store" {
  manifest = yamldecode(templatefile("${path.module}/manifest/secret_store.yaml", {
    region = var.region
    service_account_name = kubernetes_service_account.external_secrets_sa.metadata[0].name
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }))
}

# EBS CSI Driver 서비스 계정 생성
resource "kubernetes_service_account" "ebs_csi_driver_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.ebs_role.arn
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"

  values = [
    templatefile("${path.module}/values/ebs_csi_driver-values.yaml", {
      region = var.region
      service_account_name = kubernetes_service_account.ebs_csi_driver_sa.metadata[0].name
    })
  ]
}