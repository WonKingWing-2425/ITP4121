# ==================== AWS 变量（暂时可选） ====================
variable "aws_region" {
  type    = string
  default = null
}

variable "aws_vpc_id" {
  type    = string
  default = null
}

variable "aws_private_subnet_ids" {
  type    = list(string)
  default = null
}

# ==================== Azure 变量（暂时可选） ====================
variable "azure_location" {
  type    = string
  default = null
}

variable "azure_resource_group_name" {
  type    = string
  default = null
}

variable "azure_subnet_id" {
  type    = string
  default = null
}

# ==================== GCP 变量（必须传入） ====================
variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "gcp_subnetwork" {
  type = string
}

# ==================== 公共变量 ====================
variable "db_password" {
  type      = string
  sensitive = true
}