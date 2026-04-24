# GCP GKE 集群
resource "google_container_cluster" "gke" {
  provider = google.gcp
  name     = "itp4121-gke"
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.gcp_network
  subnetwork = var.gcp_subnetwork
  deletion_protection = false

  # 啟用自動伸縮（Cluster Autoscaler）
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

  # 日志和监控（发送日志到 Cloud Logging）
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

# GKE 节点池（两个节点分布在两个可用区）
resource "google_container_node_pool" "primary_nodes" {
  provider = google.gcp
  name       = "primary-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.gke.name
  node_count = 2

  # 指定两个可用区，确保节点分布在不同的私有子网
  node_locations = ["${var.gcp_region}-a", "${var.gcp_region}-b"]

  # 自动伸缩
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type = "e2-small"   # 使用 e2-small 降低 CPU 配额需求
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# 获取 GCP 客户端配置（用于生成 access token）
data "google_client_config" "default" {
  provider = google.gcp
}