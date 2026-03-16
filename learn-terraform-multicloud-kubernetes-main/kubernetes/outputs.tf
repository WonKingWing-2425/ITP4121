output "aws_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "aws_cluster_certificate" {
  value = module.eks.cluster_certificate_authority_data
}
output "aws_cluster_token" {
  value     = data.aws_eks_cluster_auth.aws.token
  sensitive = true
}

output "azure_cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].host
}
output "azure_cluster_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
}
output "azure_cluster_token" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].password
  sensitive = true
}

output "gcp_cluster_endpoint" {
  value = google_container_cluster.gke.endpoint
}
output "gcp_cluster_certificate" {
  value = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}
output "gcp_cluster_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}

data "google_client_config" "default" {
  provider = google.gcp
}