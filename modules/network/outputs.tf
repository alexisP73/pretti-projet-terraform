output "vnet_id" { value = azurerm_virtual_network.main.id }
output "subnet_ids" { value = { for k, s in azurerm_subnet.subnet : k => s.id } }
