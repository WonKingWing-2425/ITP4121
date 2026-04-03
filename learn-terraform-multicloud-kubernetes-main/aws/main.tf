# 1. 获取可用区
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. VPC 模块
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# 3. EKS 集群（使用原生资源）
resource "aws_eks_cluster" "yolo" {
  name     = "yolo-cluster"
  role_arn = "arn:aws:iam::730335209875:role/LabRole"   # 使用 Learner Lab 提供的 LabRole
  version  = "1.29"

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "dev"
    Project     = "ITP4121"
  }
}

# EKS 节点组
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.yolo.name
  node_group_name = "yolo-nodegroup"
  node_role_arn   = "arn:aws:iam::730335209875:role/LabRole"   # 同样使用 LabRole
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "yolo-worker"
    Environment = "dev"
  }

  # 确保集群创建完成后再创建节点组
  depends_on = [
    aws_eks_cluster.yolo,
  ]
}



