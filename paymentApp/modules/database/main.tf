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
    subnet_id                     = var.subnet2_id
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    primary                       = true
    private_ip_address            = "10.0.4.4"
  }
}
resource "azurerm_linux_virtual_machine" "postgres_vm" {
  name                  = "vm-postgres-selfmanaged"
  resource_group_name   = var.resource_group_name
  location              = var.location
  tags                  = var.tags
  size                  = "Standard_B2ls_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.public_key
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
    # 1. Update and install Postgres
    apt-get update
    apt-get install -y curl gnupg2 lsb-release

    # 2. Add the Official PostgreSQL Repository (PGDG)
    # This repo contains ALL versions (14, 15, 16, 17, 18...)
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    # 3. Update cache again so it sees the new versions
    apt-get update

    # 4. Now install PostgreSQL 18
    apt-get install -y postgresql-18 postgresql-contrib-18

    # Partition and mount the data disk (LUN 0)
    parted /dev/sdb --script mklabel gpt mkpart primary ext4 0% 100%
    mkfs.ext4 /dev/sdb1
    mkdir -p /var/lib/postgresql/data_disk
    mount /dev/sdb1 /var/lib/postgresql/data_disk
    echo '/dev/sdb1 /var/lib/postgresql/data_disk ext4 defaults,nofail 0 2' >> /etc/fstab

    # Configure Postgres to listen on all IPs
    echo "listen_addresses = '*'" >> /etc/postgresql/18/main/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/18/main/pg_hba.conf
    
    # Restart Postgres
    systemctl restart postgresql

    sleep 10

    sudo -u postgres psql -c "CREATE USER ${var.admin_username} WITH SUPERUSER ENCRYPTED PASSWORD '${random_password.db_pass.result}';"
    sudo -u postgres psql -c "CREATE DATABASE \"paymentapp-app-db\" OWNER ${var.admin_username};"

    # --- PHASE 2: Backup Configuration ---
    
    # 1. Create the Backup Directory
    mkdir -p /var/backups/postgresql
    chown postgres:postgres /var/backups/postgresql

    # 2. Create the Backup Script
    cat <<'SCRIPT' > /usr/local/bin/db-backup.sh
    #!/bin/bash
    
    BACKUP_DIR="/var/backups/postgresql"
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    DB_NAME="paymentapp-app-db"
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