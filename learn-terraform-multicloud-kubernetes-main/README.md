# ITP4121
Multi Cloud Kubernetes with Terraform
# Learn Terraform - Deploy Federated Multi-Cloud Kubernetes Clusters

This is a companion repository with part of the configuration for the [Deploy
Federated Multi-Cloud Kubernetes Clusters
tutorial](https://developer.hashicorp.com/terraform/tutorials/networking/multicloud-kubernetes). It contains Terraform
configuration files for you to use to learn deploy a Consul-federated
multi-cluster Kubernetes setup.


# install terraform
==========================================================================
# 1. 更新软件包列表
sudo apt-get update

# 2. 安装必要的依赖
sudo apt-get install -y gnupg software-properties-common curl

# 3. 添加 HashiCorp 的 GPG 密钥和官方仓库
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# 4. 再次更新软件包列表（以包含新仓库）
sudo apt-get update

# 5. 安装 Terraform
sudo apt-get install -y terraform

安装完成后，在终端输入 terraform --version，如果看到版本信息，就说明安装成功了。之后就可以正常执行 terraform init 了。