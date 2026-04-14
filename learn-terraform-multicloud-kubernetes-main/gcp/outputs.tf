output "network_name" {
  description = "VPC 網路名稱"
  value       = google_compute_network.main.name
}

output "subnetwork_names" {
  description = "私有子網路名稱列表"
  value       = google_compute_subnetwork.private[*].name
}

output "cluster_name" {
  description = "GKE 叢集名稱"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE 叢集控制平面的 IP 地址"
  value       = google_container_cluster.primary.endpoint
}