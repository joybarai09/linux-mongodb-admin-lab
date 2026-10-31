locals {
  vm_config = {
    host01 = {
      size       = "Standard_F1as_v7"
      private_ip = "10.20.1.10"
      role       = "admin"
    }

    mongo01 = {
      size       = "Standard_D2as_v7"
      private_ip = "10.20.1.11"
      role       = "primary"
    }

    mongo02 = {
      size       = "Standard_D2as_v7"
      private_ip = "10.20.1.12"
      role       = "secondary"
    }

    mongo03 = {
      size       = "Standard_D2as_v7"
      private_ip = "10.20.1.13"
      role       = "secondary"
    }

    mongo04 = {
      size       = "Standard_F1as_v7"
      private_ip = "10.20.1.14"
      role       = "arbiter"
    }
  }
}

resource "azurerm_public_ip" "host01" {
  name                = "pip-host01"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.mongodb.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "mongodb" {
  for_each = local.vm_config

  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.mongodb.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mongodb.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip

    public_ip_address_id = each.key == "host01" ? azurerm_public_ip.host01.id : null
  }

  tags = merge(var.tags, {
    Role = each.value.role
  })
}

resource "azurerm_linux_virtual_machine" "mongodb" {
  for_each = local.vm_config

  name                = each.key
  computer_name       = each.key
  resource_group_name = data.azurerm_resource_group.mongodb.name
  location            = var.location
  size                = each.value.size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.mongodb[each.key].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_public_key
  }

  os_disk {
    name                 = "osdisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Role = each.value.role
  })
}
