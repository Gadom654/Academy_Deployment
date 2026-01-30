locals {
  db_pass_length           = 20
  db_pass_special          = true
  db_pass_override_special = "!#$%&*()-_=+[]{}<>:?"
  db_password_name         = "${var.prefix}-db-password"
  db_username              = "${var.prefix}-db-username"
  db_diag_category_group   = "allLogs"
  db_diag_metric_category  = "allMetrics"
  db_diag_metric_enabled   = true
}
