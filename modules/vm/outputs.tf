output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_ip.ip_address
}