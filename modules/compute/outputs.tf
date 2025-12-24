output "web_vm_ids" { value = [for vm in azurerm_linux_virtual_machine.web : vm.id] }
output "db_vm_id" { value = azurerm_linux_virtual_machine.db.id }
