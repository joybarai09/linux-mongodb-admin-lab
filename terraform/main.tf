data "azurerm_resource_group" "mongodb" {
  name = var.resource_group_name
}

locals {
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}
