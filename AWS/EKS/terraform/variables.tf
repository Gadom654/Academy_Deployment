variable "tags" {
  type        = map(string)
  description = "list of tags to add to each resource"
  default = {
    "project"     = "eks"
    "environment" = "production"
    "owner"       = "Dominik"
    "created_by"  = "Terraform"
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1"
}

# --- Label / Naming Variables ---
variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  default     = "eks"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "eks"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'test'"
  default     = "prod"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between ID elements"
}

# --- Network Variables ---
variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
  default     = ["eu-north-1a", "eu-north-1b"]
}

# --- EKS Cluster Variables ---
variable "kubernetes_version" {
  type        = string
  default     = "1.34"
  description = "Desired Kubernetes master version"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "should be there a private endpoint for eks"
}

variable "endpoint_public_access" {
  type        = bool
  default     = false
  description = "should be there a private endpoint for eks"
}


variable "vpc_cni_version" {
  type        = string
  default     = null
  description = "Addon version for vpc-cni"
}

variable "vpc_cni_service_account_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM role for the VPC CNI service account"
}

variable "kube_proxy_version" {
  type        = string
  default     = null
  description = "Addon version for kube-proxy"
}

variable "coredns_version" {
  type        = string
  default     = null
  description = "Addon version for coredns"
}

# --- EKS Node Group Variables ---
variable "bastion_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for the EKS worker nodes"
}

variable "desired_size" {
  type        = number
  default     = 1
  description = "Desired number of nodes in the Node Group"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of nodes in the Node Group"
}

variable "max_size" {
  type        = number
  default     = 2
  description = "Maximum number of nodes in the Node Group"
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create local IAM policy for the cluster autoscaler"
}

variable "ami_type" {
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  description = "Ami type used in EKS node group"
}

#Bastion Variables
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Bastion instance type"
}

variable "user_data" {
  type        = list(string)
  default     = []
  description = "User data content"
}

variable "ssh_key_path" {
  type        = string
  default     = "./secrets/id_rsa.pub"
  description = "Save location to ssh public keys"
}

variable "generate_ssh_key" {
  type        = bool
  default     = false
  description = "Whether or not to generate an SSH key"
}

variable "security_groups" {
  type        = list(string)
  description = "List of Security Group IDs allowed to connect to the bastion host"
}

variable "root_block_device_encrypted" {
  type        = bool
  default     = false
  description = "Whether to encrypt the root block device"
}

variable "root_block_device_volume_size" {
  type        = number
  default     = 8
  description = "The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to."
}

variable "metadata_http_endpoint_enabled" {
  type        = bool
  default     = true
  description = "Whether the metadata service is available"
}

variable "metadata_http_put_response_hop_limit" {
  type        = number
  default     = 1
  description = "The desired HTTP PUT response hop limit (between 1 and 64) for instance metadata requests."
}

variable "metadata_http_tokens_required" {
  type        = bool
  default     = false
  description = "Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Whether to associate public IP to the instance."
}