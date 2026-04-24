output "network_name" {
  description = "VPC 網路名稱"
  value       = google_compute_network.main.name
}

output "subnetwork_names" {
  description = "私有子網路名稱列表"
  value       = google_compute_subnetwork.private[*].name
}