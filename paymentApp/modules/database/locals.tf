locals {
  postgres_dns_zone_name      = "${var.prefix}-postgres-dns-zone"
  postgres_dns_zone_link_name = "${var.prefix}-postgres-dns-zone-link"
  db_pass_length              = 20
  db_pass_special             = true
  db_pass_override_special    = "!#$%&*()-_=+[]{}<>:?"
  db_password_name            = "${var.prefix}-db-password"
  payment_db_server_name      = "${var.prefix}-payment-db"
  payment_db_version          = "13.0"
  payment_db_storage_mb       = 32768
  payment_db_sku_name         = "Standard_B1ms"
  payment_db_zone             = "1"
  payment_db_ha_mode          = "ZoneRedundant"
  payment_db_ha_standby_az    = "2"
  app_db_name                 = "${var.prefix}-app-db"
  app_db_charset              = "UTF8"
  app_db_collation            = "en_US.utf8"
}
