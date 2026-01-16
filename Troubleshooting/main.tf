#######################
# RESOURCE GROUP
#######################
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

#######################
# NETWORKING
#######################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_bastion_cidr]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_app_cidr]
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "${var.project_name}-app-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH-from-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnet_bastion_cidr
    destination_address_prefix = "*"
    description                = "Allow SSH from Bastion Subnet"
  }

  security_rule {
    name                       = "Allow-LB-VM-communication"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Allow health probe from Azure Load Balancer"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Allow HTTP traffic from Internet"
  }

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

#######################
# NAT GATEWAY
#######################
resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.project_name}-nat-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_nat_gateway" "ngw" {
  name                = "${var.project_name}-natgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_association" {
  nat_gateway_id       = azurerm_nat_gateway.ngw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "app_subnet_nat_gateway_association" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.ngw.id
}


#######################
# BASTION
#######################
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.project_name}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.project_name}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

#######################
# LOAD BALANCER
#######################
resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.project_name}-lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_lb" "lb" {
  name                = "${var.project_name}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${var.project_name}-lb-backend-pool"
}

resource "azurerm_lb_probe" "lb_probe_http" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http-probe"
  port                = 80
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule_http" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.lb_probe_http.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  disable_outbound_snat          = true
}

resource "azurerm_network_interface_backend_address_pool_association" "vm_nic_lb_association" {
  network_interface_id    = azurerm_network_interface.vm_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
}


#######################
# VIRTUAL MACHINE
#######################
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.project_name}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.project_name}-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202502181"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = filebase64("./scripts/init.sh")

  disable_password_authentication = true

  tags = {
    Project = var.project_name
    Owner   = var.owner
  }
}
