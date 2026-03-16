# Kubernetes provider for AWS
provider "kubernetes" {
  alias = "aws"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.aws.token
}

# 創建命名空間
resource "kubernetes_namespace" "app" {
  provider = kubernetes.aws
  metadata {
    name = "myapp"
  }
}

# 創建 Secret（數據庫密碼）
resource "kubernetes_secret" "db_password" {
  provider = kubernetes.aws
  metadata {
    name      = "db-password"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  data = {
    password = var.db_password
  }
  type = "Opaque"
}

# 部署 MySQL StatefulSet
resource "kubernetes_stateful_set" "mysql" {
  provider = kubernetes.aws
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    service_name = "mysql"
    replicas     = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_password.metadata[0].name
                key  = "password"
              }
            }
          }
          port {
            container_port = 3306
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  provider = kubernetes.aws
  metadata {
    name      = "mysql-pvc"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

# 部署 WordPress
resource "kubernetes_deployment" "wordpress" {
  provider = kubernetes.aws
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mysql.${kubernetes_namespace.app.metadata[0].name}.svc.cluster.local:3306"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_password.metadata[0].name
                key  = "password"
              }
            }
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  provider = kubernetes.aws
  metadata {
    name      = "wordpress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = {
      app = "wordpress"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}