locals {
  tags = {
    "project"     = "ecs"
    "environment" = "production"
    "owner"       = "Dominik"
    "created_by"  = "Terraform"
  }
  # --- General Configuration ---
  region = "eu-north-1"
  name   = "ecs" # Base name used to derive others

  # --- VPC Configuration ---
  vpc_name        = "${local.name}-vpc"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["${local.region}a", "${local.region}b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # --- ECR Configuration ---
  ecr_name = "${local.name}-repo"

  # --- ALB Configuration ---
  alb_name          = "${local.name}-alb"
  http_port         = 80
  health_check_path = "/"

  # --- ECS Configuration ---
  cluster_name   = "${local.name}-cluster"
  container_name = "${local.name}-container"
  container_port = 8080
  cpu            = 256
  memory         = 512
  desired_count  = 1
  max_capacity   = 2

  # --- Complex Object Maps ---
  alb_target_groups = {
    ecs-app = {
      name_prefix      = "${local.name}-tg"
      backend_protocol = "HTTP"
      backend_port     = local.container_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        path                = local.health_check_path
        port                = local.container_port
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
      }
      create_attachment = false
    }
  }

  ecs_services = {
    ecs-tg = {
      cpu                      = local.cpu
      memory                   = local.memory
      subnet_ids               = module.vpc.private_subnets
      assign_public_ip         = false
      desired_count            = local.desired_count
      enable_autoscaling       = true
      autoscaling_max_capacity = local.max_capacity

      container_definitions = {
        (local.container_name) = {
          image = "${aws_ecr_repository.app.repository_url}:latest"
          portMappings = [
            {
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]
          enable_cloudwatch_logging = true
          cloudwatch_log_group_name = "/ecs/hello-api"
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["ecs-app"].arn
          container_name   = local.container_name
          container_port   = local.container_port
        }
      }

      security_group_ingress_rules = {
        alb_ingress = {
          from_port                    = local.container_port
          to_port                      = local.container_port
          ip_protocol                  = "tcp"
          description                  = "Allow traffic from ALB"
          referenced_security_group_id = module.alb.security_group_id
        }
      }
      security_group_egress_rules = {
        ecr_egress = {
          to_port     = 443
          ip_protocol = "tcp"
          description = "Allow traffic to ECR"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }
}