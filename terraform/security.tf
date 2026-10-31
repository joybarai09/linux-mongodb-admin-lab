resource "azurerm_network_security_group" "mongodb" {
  name                = "nsg-mongodb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.mongodb.name

  security_rule {
    name                       = "Allow-SSH-Admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ip_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-MongoDB-Internal"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "mongodb" {
  subnet_id                 = azurerm_subnet.mongodb.id
  network_security_group_id = azurerm_network_security_group.mongodb.id
}
