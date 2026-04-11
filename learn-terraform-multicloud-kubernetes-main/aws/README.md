# ITP4121 Cloud and Data Centre Workplace Practices - Assignment 2

小组分工

OU ZHIYU：Responsible for Terraform infrastructure code for AWS cloud provider (VPC, EKS clusters, node groups, autoscaling configurations), and attempting to deploy AWS Load Balancer Controller.

AWS Partially completed work

Due to the permission restrictions in the AWS Academy Learner Lab environment (where `iam:PassRole` is disabled and the EC2 instance metadata service is inaccessible), we are unable to actually run `terraform apply` to create an EKS cluster or deploy the AWS Load Balancer Controller. However, the following Terraform code has been fully written and syntax-checked, meeting the project requirements

1. network layer（`main.tf` - VPC module）
- Create a VPC with a CIDR of ` 192.168.0.0/16 `.
- Create two private subnets (` 10.01.0/24 `, ` 10.02.0/24 `) for EKS node groups.
- Create two public subnets (` 10.0101.0/24 `, ` 10.0102.0/24 `) for NAT gateway and load balancer.
- Enable NAT gateway to ensure that private subnet nodes can access the external network.

2. EKS cluster (aws_eks_cluster resource)
- Cluster name: yolo cluster`
- Kubernetes version: ` 1.29`
- Deploy the control plane in a private subnet, enabling access to both public and private endpoints.

3. EKS Node Group (` aws_eks_node_group ` resource)
- Node group name: ` yolo nodegroup '`
- Instance type: ` t3.medium '`
- Number of nodes: Expected 2, minimum 2, maximum 5 (meeting job requirements of "2 VMs in 2 private subnets" and "cluster auto scaling")
- Use 'LabRole' as the node IAM role.

4. Automatic scaling configuration
- The 'scaleingconfig' of the node group is set to 'desired_size=2', 'min_Size=2', and 'max_Size=5'.
- If automatic scaling based on Pod load is required, Cluster AutoScaler (managed by Alex or implemented through GCP) needs to be installed in the cluster.

5. AWS Load Balancing Controller (attempted deployment but failed)
- I installed AWS Load Balancing Controller through Helm, but due to the inability of Learner Lab environment to obtain IAM credentials from EC2 metadata service (IMDS timeout), the controller Pod has been in the 'CrashLoopBackOff' state and cannot create ALB.
- Therefore, Ingress、SSL/TLS、 Use functions such as application logs to complete tasks for other members.

## Environmental limitations encountered

- Iam: PassRole 'permission is missing * *: The Learner Lab policy prohibits passing' LabRole 'to the EKS service, resulting in the inability to create an EKS cluster (although the code is correct, it cannot be actually applied).
- EC2 metadata service unreachable * *: Unable to obtain IAM credentials through IMDS in Kubernetes Pod, resulting in AWS load balancer controller unable to call AWS API.

Due to these limitations, the AWS section is only submitted as code design and documentation, and the actual operating environment is undertaken by GCP.

## GCP 部分需要完成的任务（成员二）

为了满足作业所有要求，成员二需要在 GCP 上实现以下功能：

| 作业要求 | GCP 实现方式 |
|---------|-------------|
| Kubernetes 集群部署在 VPC 内，2 个 VM 在 2 个私有子网 | 创建 VPC 网络，使用 Private GKE 集群，节点池使用私有子网，初始 2 个节点 |
| 集群自动伸缩 | GKE 节点池配置自动伸缩（`autoscaling`） |
| 连接 Progress Database（StatefulSet） | 使用 PostgreSQL StatefulSet + PersistentVolume（或 Cloud SQL） |
| 使用 Kubernetes Secret | 存储数据库密码等敏感信息 |
| 云原生负载均衡器（Ingress） | 部署 GCE Ingress Controller 或使用 GKE 原生 Ingress（`ingress.gcp.kubernetes.io`） |
| SSL/TLS | 使用 Google 管理的证书（`ManagedCertificate`）或自签名证书 |
| 应用日志发送到云日志服务 | GKE 默认集成 Cloud Logging，只需在节点池启用 |
| 多云高可用 | 通过 Cloud DNS 配置故障转移，将流量指向 GCP（主）和 AWS（备，由于 AWS 未部署，可仅做设计说明） |

## 如何运行 AWS Terraform 代码（如果权限允许）

1. 配置 AWS CLI（使用有足够权限的 IAM 用户）。
2. 进入 `terraform/aws/` 目录。
3. 运行 `terraform init`。
4. 运行 `terraform plan`。
5. 运行 `terraform apply`。

由于 Learner Lab 的限制，实际执行会失败，但代码本身是正确的。


## 代码仓库结构
├── terraform/
│ ├── aws/
│ │ ├── main.tf # VPC、EKS、节点组
│ │ ├── variables.tf # 输入变量
│ │ ├── outputs.tf # 输出（VPC ID、集群名称等）
│ │ └── provider.tf # Terraform 和 AWS Provider 配置
│ ├── gcp/ # 成员二负责
│ └── azure/ # 成员三负责（如果有）
├── README.md # 本文件
└── .gitignore