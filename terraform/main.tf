terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.80"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "3307e1c4-c1ce-4bcd-b25e-832db8e4c4f1"
}

############################
# Resource Group
############################

resource "azurerm_resource_group" "rg" {
  name     = "acctestrg"
  location = "centralus"
}

############################
# Virtual Network
############################

resource "azurerm_virtual_network" "vnet" {
  name                = "acctvn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [
    "10.0.0.0/16"
  ]
}

############################
# Subnet
############################

resource "azurerm_subnet" "subnet" {
  name                 = "acctsub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}

############################
# Public IP
############################

resource "azurerm_public_ip" "pip" {
  name                = "public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    environment = "staging"
  }
}

############################
# Network Security Group
############################

resource "azurerm_network_security_group" "nsg" {

  name                = "demo-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "staging"
  }
}

############################
# SSH Rule
############################

resource "azurerm_network_security_rule" "ssh" {

  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "22"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

############################
# App Rule
############################

resource "azurerm_network_security_rule" "app8080" {

  name                        = "Allow8080"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "8080"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

############################
# Network Interface
############################

resource "azurerm_network_interface" "nic" {

  name                = "demo-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  depends_on = [
    azurerm_subnet.subnet
  ]
}

############################
# Associate NSG
############################

resource "azurerm_network_interface_security_group_association" "assoc" {

  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

############################
# Linux VM
############################

resource "azurerm_linux_virtual_machine" "vm" {

  name                = "demo-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  size = "Standard_D2s_v3"

  admin_username = "azureuser"

  disable_password_authentication = false

  admin_password = "Password1234!"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {

    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {

    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku        = "22_04-lts"
    version    = "latest"
  }

  depends_on = [
    azurerm_network_interface_security_group_association.assoc
  ]
}

############################
# Outputs
############################

output "public_ip_address" {

  value = azurerm_public_ip.pip.ip_address
}

output "vm_public_ip" {

  value = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {

  value = "ssh azureuser@${azurerm_public_ip.pip.ip_address}"
}
