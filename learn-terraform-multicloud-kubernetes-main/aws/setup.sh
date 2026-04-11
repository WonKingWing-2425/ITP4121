#!/bin/bash
set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   AWS EKS 环境自动部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查 AWS 凭证环境变量
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_SESSION_TOKEN" ]]; then
    echo -e "${RED}错误：请先设置以下环境变量：${NC}"
    echo "  export AWS_ACCESS_KEY_ID=你的AccessKey"
    echo "  export AWS_SECRET_ACCESS_KEY=你的SecretKey"
    echo "  export AWS_SESSION_TOKEN=你的SessionToken"
    exit 1
fi

# 检查必要命令
for cmd in terraform aws kubectl; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}错误：未找到命令 '$cmd'，请先安装。${NC}"
        exit 1
    fi
done

# 进入 Terraform 目录
# 自动查找 terraform/aws 目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_AWS_DIR=$(find "$SCRIPT_DIR" -type d -path "*/terraform/aws" | head -1)
if [[ -z "$TERRAFORM_AWS_DIR" ]]; then
    echo -e "${RED}错误：找不到 terraform/aws 目录${NC}"
    exit 1
fi
cd "$TERRAFORM_AWS_DIR"

echo -e "${YELLOW}[1/6] 初始化 Terraform...${NC}"
terraform init -upgrade

echo -e "${YELLOW}[2/6] 部署 AWS 基础设施（VPC, EKS, 节点组）...${NC}"
echo -e "${YELLOW}这可能需要 15-20 分钟，请耐心等待...${NC}"
terraform apply -auto-approve

# 获取集群名称（从 Terraform 输出或固定名称）
CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "yolo-cluster")
echo -e "${GREEN}集群名称: $CLUSTER_NAME${NC}"

echo -e "${YELLOW}[3/6] 配置 kubectl...${NC}"
aws eks update-kubeconfig --region us-east-1 --name "$CLUSTER_NAME"

echo -e "${YELLOW}[4/6] 等待节点组就绪...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo -e "${YELLOW}[5/6] 创建 Kubernetes Secret (数据库密码)...${NC}"
kubectl delete secret db-secret --ignore-not-found
kubectl create secret generic db-secret --from-literal=password=mysecretpassword

echo -e "${YELLOW}[6/6] 部署 PostgreSQL (使用 emptyDir 临时存储)...${NC}"
kubectl delete statefulset postgres --ignore-not-found
kubectl delete svc postgres --ignore-not-found

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: POSTGRES_DB
          value: peopleflow
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-data
        emptyDir: {}
EOF

echo -e "${YELLOW}等待 PostgreSQL Pod 启动...${NC}"
kubectl wait --for=condition=Ready pod -l app=postgres --timeout=120s

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}部署完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "你可以运行以下命令测试数据库连接："
echo -e "  kubectl run postgres-client --rm -it --image=postgres:13 -- bash"
echo -e "然后在容器内执行："
echo -e "  psql -h postgres -U postgres -d peopleflow"
echo -e "  密码: mysecretpassword"
echo -e ""
echo -e "实验结束后，请运行 'terraform destroy' 清理资源。"terraform destroy