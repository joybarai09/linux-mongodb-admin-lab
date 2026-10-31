output "vm_private_ips" {
  description = "Private IP addresses of all virtual machines"

  value = {
    for name, nic in azurerm_network_interface.mongodb :
    name => nic.private_ip_address
  }
}

output "host01_public_ip" {
  description = "Public IP address of admin VM"
  value       = azurerm_public_ip.host01.ip_address
}

output "vm_sizes" {
  description = "VM sizes deployed"

  value = {
    for name, vm in azurerm_linux_virtual_machine.mongodb :
    name => vm.size
  }
}
