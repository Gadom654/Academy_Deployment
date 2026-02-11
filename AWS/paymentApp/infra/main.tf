# Label Module
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = var.namespace
  name      = var.name
  stage     = var.stage
  delimiter = var.delimiter
  tags      = var.tags
}
# DB Module
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}
module "rds" {
  source  = "cloudposse/rds/aws"
  version = "1.2.0"

  engine         = "postgres"
  engine_version = "18.1"
  instance_class = "db.c6gd.medium"
  name           = "postgresdb"

  database_user     = var.db_username
  database_password = random_password.db_password.result

  allocated_storage = 20

  security_group_ids = [module.eks_cluster.eks_cluster_managed_security_group_id]

  vpc_id             = data.terraform_remote_state.platform.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.platform.outputs.database_subnet_ids
  db_parameter_group = "postgres18"
  database_port      = 5432

  publicly_accessible = false
  multi_az            = true
  storage_encrypted   = true

  context = module.label.context
}
module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "3.4.0"

  desired_size   = var.desired_size
  instance_types = [var.instance_type]
  subnet_ids     = data.terraform_remote_state.platform.outputs.private_subnet_ids
  min_size       = var.min_size
  max_size       = var.max_size
  cluster_name   = module.eks_cluster.eks_cluster_id
  node_role_arn  = [data.terraform_remote_state.platform.outputs.eks_node_group_role_arn]

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = var.autoscaling_policies_enabled

  ami_type = var.ami_type

  context = module.label.context
}
# EKS Cluster Module
module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "4.8.0"

  subnet_ids                   = data.terraform_remote_state.platform.outputs.private_subnet_ids
  kubernetes_version           = var.kubernetes_version
  oidc_provider_enabled        = true
  create_eks_service_role      = false
  eks_cluster_service_role_arn = data.terraform_remote_state.platform.outputs.eks_cluster_role_arn

  access_entry_map = {
    (data.terraform_remote_state.platform.outputs.eks_cluster_role_arn) = {
      access_policy_associations = {
        AmazonEKSClusterAdminPolicy = {}
      }
    }
    ("arn:aws:iam::268836235026:role/github-actions-applyer-role") = {
      access_policy_associations = {
        AmazonEKSClusterAdminPolicy = {}
      }
    }
  }

  allowed_cidr_blocks = [
    "10.0.0.0/16",
    "10.8.0.0/24"
  ]

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  addons = [
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version
    {
      addon_name                  = "vpc-cni"
      addon_version               = var.vpc_cni_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = var.vpc_cni_service_account_role_arn
    },
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
    {
      addon_name                  = "kube-proxy"
      addon_version               = var.kube_proxy_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
    {
      addon_name                  = "coredns"
      addon_version               = var.coredns_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "aws-secrets-store-csi-driver-provider"
      addon_version               = var.secret_store_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
      configuration_values = jsonencode({
        "secrets-store-csi-driver" = {
          syncSecret = {
            enabled = true
          }
          enableSecretRotation = true
          rotationPollInterval = "3600s"
        }
      })
    },
    {
      addon_name                  = "metrics-server"
      addon_version               = var.metrics-server_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "eks-pod-identity-agent"
      addon_version               = var.eks-pod-identity-agent_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
  ]
  addons_depends_on = [module.eks_node_group]

  context = module.label.context
}

# Parameter Store Module
module "ssm_parameters" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.13.0"

  parameter_write = [
    {
      name        = "paymentapp-db-password"
      description = "Master password for Postgres RDS"
      type        = "SecureString"
      value       = random_password.db_password.result
      overwrite   = true
    },
    {
      name        = "paymentapp-db-username"
      description = "Master password for Postgres RDS"
      type        = "String"
      value       = var.db_username
      overwrite   = true
    }
  ]

  context = module.label.context
}

# ALB controller module
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lbc_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lbc_iam_policy.response_body
}
module "lbc_role" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "2.1.0"

  namespace = "kube-system"
  name      = "aws-load-balancer-controller"

  eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  service_account_name        = "aws-load-balancer-controller"
  service_account_namespace   = "kube-system"

  aws_iam_policy_document = [aws_iam_policy.lbc_policy.policy]

  context = module.label.context
}
resource "helm_release" "lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.17.1"

  values = [
    yamlencode({
      clusterName = module.eks_cluster.eks_cluster_id
      vpcId       = data.terraform_remote_state.platform.outputs.vpc_id
      region      = var.region
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [module.lbc_role]
}