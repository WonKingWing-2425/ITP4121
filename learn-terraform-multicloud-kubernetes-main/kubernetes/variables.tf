# AWS
variable "aws_region" {
  type = string
}
variable "aws_vpc_id" {
  type = string
}
variable "aws_private_subnet_ids" {
  type = list(string)
}

# Azure
variable "azure_location" {
  type = string
}
variable "azure_resource_group_name" {
  type = string
}
variable "azure_subnet_id" {
  type = string
}

# GCP
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

# Common
variable "db_password" {
  type      = string
  sensitive = true
}