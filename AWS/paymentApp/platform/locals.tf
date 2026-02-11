locals {
  tags = { "kubernetes.io/cluster/${module.label.id}-cluster" = "shared" }

  public_subnets_additional_tags = {
    "kubernetes.io/role/elb" : 1
  }
  private_subnets_additional_tags = {
    "kubernetes.io/role/internal-elb" : 1
  }
  vpn_cidr = "10.8.0.0/24"
}