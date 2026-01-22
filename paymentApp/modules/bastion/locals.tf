locals {
  bastion_ip_name        = "${var.prefix}-bastion-ip"
  bastion_name           = "${var.prefix}-bastion"
  bastion_sku            = "Standard"
  bastion_ip_config_name = "bastion-ip-config"
}