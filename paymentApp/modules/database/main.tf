#################################
### Database Private DNS Zone ###
#################################
resource "azurerm_private_dns_zone" "postgres_dns_zone" {
  name                = local.postgres_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link the DNS Zone to the VNet so AKS can resolve the DB address
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_zone_link" {
  name                  = local.postgres_dns_zone_link_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
}
#########################
### Database Password ###
#########################
resource "random_password" "db_pass" {
  length           = local.db_pass_length
  special          = local.db_pass_special
  override_special = local.db_pass_override_special
}
resource "azurerm_key_vault_secret" "db_password" {
  name         = local.db_password_name
  value        = random_password.db_pass.result
  key_vault_id = var.key_vault_id
}
resource "azurerm_key_vault_secret" "db_username" {
  name         = local.db_username
  value        = var.admin_username
  key_vault_id = var.key_vault_id
}
################
### Database ###
################
resource "azurerm_postgresql_flexible_server" "payment_db" {
  name                = local.payment_db_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  version             = local.payment_db_version

  public_network_access_enabled = false

  zone = local.payment_db_zone

  # Network injection
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns_zone.id

  administrator_login    = var.admin_username
  administrator_password = random_password.db_pass.result

  storage_mb = local.payment_db_storage_mb
  sku_name   = local.payment_db_sku_name

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres_dns_zone_link]
}

resource "azurerm_postgresql_flexible_server_database" "app_db" {
  name      = local.app_db_name
  server_id = azurerm_postgresql_flexible_server.payment_db.id
  charset   = local.app_db_charset
  collation = local.app_db_collation
}
#################
# Database logs #
#################
resource "azurerm_monitor_diagnostic_setting" "db_diag" {
  name                       = local.db_diag_name
  target_resource_id         = azurerm_postgresql_flexible_server.payment_db.id
  log_analytics_workspace_id = var.law_id

  enabled_log {
    category_group = local.db_diag_category_group
  }

  metric {
    category = local.db_diag_metric_category
    enabled  = local.db_diag_metric_enabled
  }
}
###################
### VM Database ###
###################
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-postgres-tiny"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "postgres_vm" {
  name                  = "vm-postgres-selfmanaged"
  resource_group_name   = var.resource_group_name
  location              = var.location
  tags                  = var.tags
  size                  = "standard_B2ls_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    # Update and install Postgres
    apt-get update
    apt-get install -y postgresql-14 postgresql-contrib-14

    # Partition and mount the data disk (LUN 0)
    parted /dev/sdc --script mklabel gpt mkpart primary ext4 0% 100%
    mkfs.ext4 /dev/sdc1
    mkdir -p /var/lib/postgresql/data_disk
    mount /dev/sdc1 /var/lib/postgresql/data_disk
    echo '/dev/sdc1 /var/lib/postgresql/data_disk ext4 defaults,nofail 0 2' >> /etc/fstab

    # Configure Postgres to listen on all IPs
    echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/14/main/pg_hba.conf
    
    # Restart Postgres
    systemctl restart postgresql

    sleep 10

    sudo -u postgres psql -c "CREATE USER ${var.admin_username} WITH SUPERUSER ENCRYPTED PASSWORD '${var.db_password}';"
    sudo -u postgres psql -c "CREATE DATABASE mytestdb OWNER ${random_password.db_pass.result};"

    # --- PHASE 2: Backup Configuration ---
    
    # 1. Create the Backup Directory
    mkdir -p /var/backups/postgresql
    chown postgres:postgres /var/backups/postgresql

    # 2. Create the Backup Script
    cat <<'SCRIPT' > /usr/local/bin/db-backup.sh
    #!/bin/bash
    
    BACKUP_DIR="/var/backups/postgresql"
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    DB_NAME="mytestdb"
    FILENAME="$BACKUP_DIR/db-backup-$DB_NAME-$TIMESTAMP.sql"

    # Run pg_dump as the 'postgres' user
    # We use sudo -u postgres so we don't need to manage passwords in this script
    if sudo -u postgres pg_dump "$DB_NAME" > "$FILENAME"; then
        echo "Backup successful: $FILENAME"
        # Optional: Delete backups older than 7 days to save space
        find "$BACKUP_DIR" -type f -name "*.sql" -mtime +7 -delete
    else
        echo "Backup failed" >&2
        exit 1
    fi
    SCRIPT

    # 3. Make the script executable
    chmod +x /usr/local/bin/db-backup.sh

    # 4. Setup Cron Job (Run daily at 02:00)
    # We write directly to /etc/cron.d which is cleaner for automation than `crontab -e`
    echo "0 2 * * * root /usr/local/bin/db-backup.sh" > /etc/cron.d/postgres-backup
  EOF
  )
}

resource "azurerm_managed_disk" "postgres_data" {
  name                 = "disk-postgres-data"
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.postgres_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.postgres_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}