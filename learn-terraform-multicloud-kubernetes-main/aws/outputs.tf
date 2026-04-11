output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}


output "eks_cluster_name" {
  value = aws_eks_cluster.yolo.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.yolo.endpoint
}

output "eks_cluster_ca_certificate" {
  value = aws_eks_cluster.yolo.certificate_authority[0].data
}