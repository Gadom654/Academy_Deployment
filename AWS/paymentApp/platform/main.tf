data "aws_caller_identity" "current" {}
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
# VPC Module
module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "3.0.0"

  ipv4_primary_cidr_block = "10.0.0.0/16"

  tags    = local.tags
  context = module.label.context
}
# Dynamic Subnets Module
module "eks_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "3.1.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = ["10.0.0.0/18"]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  public_subnets_additional_tags  = local.public_subnets_additional_tags
  private_subnets_additional_tags = local.private_subnets_additional_tags

  tags    = local.tags
  context = module.label.context
}

module "db_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "3.1.0"

  availability_zones     = var.availability_zones
  vpc_id                 = module.vpc.vpc_id
  igw_id                 = []
  ipv4_cidr_block        = ["10.0.64.0/20"]
  nat_gateway_enabled    = false
  public_subnets_enabled = false

  private_subnets_additional_tags = local.private_subnets_additional_tags

  tags    = local.tags
  context = module.label.context
}
# IAM Roles
module "eks_cluster_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.22.0"

  policy_document_count = 0

  name             = "eks-cluster"
  role_description = "Rola dla EKS Control Plane"
  principals       = { "Service" = ["eks.amazonaws.com"] }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]

  context = module.label.context
}

module "eks_node_group_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.22.0"

  policy_document_count = 0

  name             = "eks-node-group"
  role_description = "Rola dla worker nodes w EKS"
  principals       = { "Service" = ["ec2.amazonaws.com"] }
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  context = module.label.context
}

module "rds_admin_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.22.0"

  policy_document_count = 0

  name                = "rds-admin"
  role_description    = "Rola do pelnego zarzadzania instancjami RDS"
  principals          = { "AWS" = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] }
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRDSFullAccess"]

  context = module.label.context
}

module "eks_lb_controller_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.22.0"

  policy_document_count = 0

  name             = "eks-lb-controller"
  role_description = "Rola dla AWS LB Controller w EKS"

  principals = { "Service" = ["ec2.amazonaws.com"] }

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"]

  context = module.label.context
}
# WAF Module
module "waf" {
  source  = "cloudposse/waf/aws"
  version = "1.17.0"

  scope = "REGIONAL"

  default_action = "allow"

  managed_rule_group_statement_rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 1
      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      }
    },
    {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 2
      statement = {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 3
      statement = {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      }
    }
  ]

  visibility_config = {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "waf-main-metrics"
  }

  context = module.label.context
}

# ARCs
# Repo for api
module "ecr_payment_api" {
  source  = "cloudposse/ecr/aws"
  version = "0.40.0"

  name                 = "payment-api"
  use_fullname         = false
  image_tag_mutability = "IMMUTABLE"
  scan_images_on_push  = true

  context = module.label.context
}

# Repo for worker
module "ecr_payment_worker" {
  source  = "cloudposse/ecr/aws"
  version = "0.40.0"

  name                 = "payment-worker"
  use_fullname         = false
  image_tag_mutability = "IMMUTABLE"
  scan_images_on_push  = true

  context = module.label.context
}

# Repo for helm chart
module "ecr_payment_chart" {
  source  = "cloudposse/ecr/aws"
  version = "0.40.0"

  name                 = "payment-chart"
  use_fullname         = false
  image_tag_mutability = "MUTABLE"

  context = module.label.context
}

# OpenVPN Instance
module "instance" {
  source  = "cloudposse/ec2-instance/aws"
  version = "2.0.0"
  name    = "openvpn"

  # Instance Configuration
  instance_type = "t3.small"
  ami           = "ami-0c7217cdde317cfec"
  vpc_id        = data.terraform_remote_state.platform.outputs.vpc_id
  subnet        = data.terraform_remote_state.platform.outputs.public_subnet_ids[0]

  # Networking
  associate_public_ip_address = true

  # Security Group Rules for OpenVPN (UDP 1194)
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
    },
    {
      type        = "ingress"
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow OpenVPN traffic"
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  # Automation script to install OpenVPN
  user_data = <<-EOF
              #!/bin/bash
              curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
              chmod +x openvpn-install.sh
              ./openvpn-install.sh install
              ./openvpn-install.sh client add dominik
              EOF

  context = module.label.context
}