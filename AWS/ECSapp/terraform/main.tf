module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true # Set to false for production high availability

  tags = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = local.alb_name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_group_ingress_rules = {
    all_http = {
      from_port   = local.http_port
      to_port     = local.http_port
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all_http = {
      from_port   = local.container_port
      to_port     = local.container_port
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = local.http_port
      protocol = "HTTP"
      forward  = { target_group_key = "ecs-app" }
    }
  }

  target_groups = local.alb_target_groups
  tags          = local.tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name                           = local.cluster_name
  cluster_configuration                  = local.cluster_configuration
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 14
  services                               = local.ecs_services

  tags = local.tags
}

resource "aws_ecr_repository" "app" {
  name = local.ecr_name
  tags = local.tags
}