module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = var.namespace
  name      = var.name
  stage     = var.stage
  delimiter = var.delimiter
  tags      = var.tags
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "3.0.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  tags    = local.tags
  context = module.label.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "3.1.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  public_subnets_additional_tags  = local.public_subnets_additional_tags
  private_subnets_additional_tags = local.private_subnets_additional_tags

  tags    = local.tags
  context = module.label.context
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "3.4.0"

  desired_size   = var.desired_size
  instance_types = [var.instance_type]
  subnet_ids     = module.subnets.private_subnet_ids
  min_size       = var.min_size
  max_size       = var.max_size
  cluster_name   = module.eks_cluster.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = var.autoscaling_policies_enabled

  ami_type = var.ami_type

  context = module.label.context
}

module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "4.8.0"

  subnet_ids            = concat(module.subnets.private_subnet_ids, module.subnets.public_subnet_ids)
  kubernetes_version    = var.kubernetes_version
  oidc_provider_enabled = true

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
  ]
  addons_depends_on = [module.eks_node_group]

  context = module.label.context

  cluster_depends_on = [module.subnets]
}