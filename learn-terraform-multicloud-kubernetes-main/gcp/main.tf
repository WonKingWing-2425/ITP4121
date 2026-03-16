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
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# 創建 VPC
resource "google_compute_network" "main" {
  name                    = "itp4121-vpc"
  auto_create_subnetworks = false
  depends_on = [google_project_service.compute]
}

# 創建兩個私有子網
resource "google_compute_subnetwork" "private" {
  count         = 2
  name          = "private-${count.index + 1}"
  ip_cidr_range = cidrsubnet("10.2.0.0/16", 8, count.index)
  region        = var.region
  network       = google_compute_network.main.id
}

output "network_name" {
  value = google_compute_network.main.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.private[0].name
}