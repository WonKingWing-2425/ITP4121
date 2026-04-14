# 1. 刪除會報錯的 Yarn 來源清單，並安裝基礎工具
sudo rm -f /etc/apt/sources.list.d/yarn*.list
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common apt-transport-https ca-certificates curl

# 2. 加入 HashiCorp (Terraform) 金鑰 (--yes 強制覆蓋，避免卡住)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# 3. 加入 Google Cloud 金鑰 (--yes 強制覆蓋，避免卡住)
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# 4. 更新清單並正式安裝 Terraform 與 GCP 工具
sudo apt-get update
sudo apt-get install -y terraform google-cloud-cli


gcloud auth application-default login

terraform init -upgrade
terraform plan
terraform apply
terraform destroy
