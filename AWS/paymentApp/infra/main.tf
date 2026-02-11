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
module "rds" {
  source  = "cloudposse/rds/aws"
  version = "1.2.0"

  engine         = "postgres"
  engine_version = "18.1"
  instance_class = "db.c6gd.medium"
  name           = "postgresdb"

  database_user     = var.db_username
  database_password = var.db_password

  allocated_storage = 20

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
    (data.aws_caller_identity.applyer.arn) = {
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