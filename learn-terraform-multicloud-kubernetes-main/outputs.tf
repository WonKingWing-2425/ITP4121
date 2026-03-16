output "aws_cluster_endpoint" {
  value = module.kubernetes.aws_cluster_endpoint
}

output "azure_cluster_endpoint" {
  value = module.kubernetes.azure_cluster_endpoint
}

output "gcp_cluster_endpoint" {
  value = module.kubernetes.gcp_cluster_endpoint
}