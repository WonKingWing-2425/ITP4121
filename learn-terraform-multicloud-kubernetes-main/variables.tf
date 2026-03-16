variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-east-1"
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "eastasia"
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "itp4121-rg"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "asia-east1"
}

variable "db_password" {
  description = "Database root password"
  type        = string
  sensitive   = true
}