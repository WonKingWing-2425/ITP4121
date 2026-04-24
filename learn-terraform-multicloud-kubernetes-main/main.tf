terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# 注释 AWS 基础设施模块（Member 1）
# module "aws_infra" {
#   source = "./aws"
#   region = var.aws_region
# }

# 注释 Azure 基础设施模块（Member 2）
# module "azure_infra" {
#   source = "./azure"
#   location           = var.azure_location
#   resource_group_name = var.azure_resource_group_name
# }

# GCP 基础设施模块（Member 3）
module "gcp_infra" {
  source = "./gcp"
  project_id = var.gcp_project_id
  region     = var.gcp_region
}

# Kubernetes 模块（Member 4）
module "kubernetes" {
  source = "./kubernetes"

  # AWS 相关参数（暂时注释）
  # aws_vpc_id             = module.aws_infra.vpc_id
  # aws_private_subnet_ids = module.aws_infra.private_subnet_ids
  # aws_region             = var.aws_region

  # Azure 相关参数（暂时注释）
  # azure_resource_group_name = var.azure_resource_group_name
  # azure_subnet_id           = module.azure_infra.aks_subnet_id
  # azure_location            = var.azure_location

  # GCP 相关参数
  gcp_project_id = var.gcp_project_id
  gcp_network    = module.gcp_infra.network_name
  gcp_subnetwork = module.gcp_infra.subnetwork_names[0]   # 注意是列表，取第一个
  gcp_region     = var.gcp_region

  db_password = var.db_password
}