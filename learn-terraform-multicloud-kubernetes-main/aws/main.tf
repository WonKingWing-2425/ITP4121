# 1. 获取可用区
# data "aws_availability_zones" "available" {
#   state = "available"
# }

data "aws_caller_identity" "current" {}   #动态获取当前账号 ID

# 2. VPC 模块（你的原代码，完全不动）
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# 3. EKS 集群（修复：统一使用当前账号的 LabRole）
resource "aws_eks_cluster" "yolo" {
  name     = "yolo-cluster"
  # 你的当前账号ID：
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
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

# EKS 节点组（修复：和集群用同一个角色！！）
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.yolo.name
  node_group_name = "yolo-nodegroup"
  # 重点！！必须和上面一模一样的账号ID！！
  node_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids      = module.vpc.private_subnets

    # 使用 AL2023 AMI
  ami_type = "AL2023_x86_64_STANDARD"

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

  depends_on = [aws_eks_cluster.yolo]
}