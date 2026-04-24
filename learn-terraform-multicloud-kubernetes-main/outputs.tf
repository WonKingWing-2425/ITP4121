output "gcp_cluster_endpoint" {
  value = module.kubernetes.gcp_cluster_endpoint
}

output "gcp_cluster_certificate" {
  value = module.kubernetes.gcp_cluster_certificate
  sensitive = true
}

output "gcp_cluster_token" {
  value = module.kubernetes.gcp_cluster_token
  sensitive = true
}