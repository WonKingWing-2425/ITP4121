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
  private_ip_google_access = true
}

# 建立 Cloud Router 與 NAT
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