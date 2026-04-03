#!/bin/bash
# 安装 Terraform 所需依赖
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# 添加 HashiCorp 官方 GPG 密钥
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# 添加 HashiCorp 官方 Linux 软件源
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# 安装 Terraform
sudo apt update && sudo apt install terraform -y

echo "Terraform 安装完成！"
sudo apt update && sudo apt install terraform -y

echo "Terraform 安装完成！"
