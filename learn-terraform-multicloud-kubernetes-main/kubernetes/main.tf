# 獲取當前 AWS 調用者身份（用於 token）
data "aws_caller_identity" "current" {
  provider = aws.aws
}

# AWS EKS 集群模塊
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  providers = {
    aws = aws.aws
  }

  cluster_name    = "itp4121-eks"
  cluster_version = "1.27"

  vpc_id     = var.aws_vpc_id
  subnet_ids = var.aws_private_subnet_ids

  eks_managed_node_groups = {
    main = {
      desired_size = 2
      min_size     = 1
      max_size     = 5
      instance_types = ["t3.medium"]
    }
  }

  # 開啟集群自動伸縮（需要額外配置，這裡只是標誌）
  cluster_autoscaler_enabled = true
}

# 獲取集群 token
data "aws_eks_cluster_auth" "aws" {
  provider = aws.aws
  name     = module.eks.cluster_name
}

# Azure AKS 集群
resource "azurerm_kubernetes_cluster" "aks" {
  provider = azurerm.azure
  name                = "itp4121-aks"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  dns_prefix          = "itp4121aks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = var.azure_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }
}

# GCP GKE 集群
resource "google_container_cluster" "gke" {
  provider = google.gcp
  name     = "itp4121-gke"
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.gcp_network
  subnetwork = var.gcp_subnetwork

  # 啟用自動伸縮
  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 10
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 1
      maximum       = 64
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  provider = google.gcp
  name       = "primary-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.gke.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# 輸出集群信息（後面會放在 outputs.tf）