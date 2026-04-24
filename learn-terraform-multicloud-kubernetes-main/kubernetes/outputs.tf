# GCP 集群输出
output "gcp_cluster_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "gcp_cluster_certificate" {
  value = google_container_cluster.gke.master_auth[0].cluster_ca_certificate
}

output "gcp_cluster_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}