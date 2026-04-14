terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 啟用必要 API 
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# 創建 VPC 
resource "google_compute_network" "main" {
  name                    = "itp4121-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

# 創建兩個私有子網 
resource "google_compute_subnetwork" "private" {
  count                    = 2
  name                     = "private-subnet-${count.index + 1}"
  ip_cidr_range            = cidrsubnet("10.2.0.0/16", 8, count.index)
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true # 必須開啟才能讓私有子網存取 Google 服務
}

# 建立 Cloud Router 與 NAT (私有子網對外連線必備)
resource "google_compute_router" "router" {
  name    = "itp4121-router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "itp4121-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 建立 GKE 叢集
resource "google_container_cluster" "primary" {
  name     = "itp4121-gke-cluster"
  location = var.region
  deletion_protection = false

  # 刪除預設的 node pool，以便我們自訂具有 AutoScaler 的 node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.private[0].id

  # 串流應用程式日誌資料到雲端日誌服務 (GCP Stackdriver) 
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  depends_on = [google_project_service.container]
}

# 建立 GKE Node Pool 並設定 Cluster AutoScaler 
resource "google_container_node_pool" "primary_nodes" {
  name       = "itp4121-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  
  # 明確指定兩個可用區(Zones)，確保能達成 2 個 VM 運行在 2 個私有子網的要求 
  node_locations = ["${var.region}-a", "${var.region}-b"]

  # 每個 Zone 1 個節點，2 個 Zone 共 2 個節點 (VM)
  initial_node_count = 1 

  # 設定自動擴展 
  autoscaling {
    min_node_count = 1
    max_node_count = 3 
  }

  node_config {
    machine_type = "e2-medium"
    
    # 賦予節點寫入日誌到 Stackdriver 的權限
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}