# Network Outputs
output "vpc_id" {
  description = "ID sieci VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Zakres CIDR sieci VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "ID podsieci publicznych (dla ALB i NAT)"
  value       = module.eks_subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "ID podsieci prywatnych (dla EKS Worker Nodes)"
  value       = module.eks_subnets.private_subnet_ids
}

output "database_subnet_ids" {
  description = "ID izolowanych podsieci dla RDS"
  value       = module.db_subnets.private_subnet_ids
}
# IAM Roles
output "eks_cluster_role_arn" {
  description = "ARN roli dla EKS Control Plane"
  value       = module.eks_cluster_role.arn
}

output "eks_node_group_role_arn" {
  description = "ARN roli dla EKS Node Groups"
  value       = module.eks_node_group_role.arn
}

output "lb_controller_role_arn" {
  description = "ARN roli dla AWS Load Balancer Controller"
  value       = module.eks_lb_controller_role.arn
}

output "rds_admin_role_arn" {
  description = "ARN roli administratora RDS"
  value       = module.rds_admin_role.arn
}

# WAF Outputs
output "waf_acl_arn" {
  description = "ARN of the WAFv2 Web ACL to be used in Ingress annotations"
  value       = module.waf.arn
}