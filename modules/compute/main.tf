# VMs Web
resource "azurerm_linux_virtual_machine" "web" {
  count               = 2
  name                = "web-${count.index}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size_web
  admin_username      = var.admin_user
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.admin_user
    public_key = file("~/.ssh/id_rsa.pub")
  }
  custom_data = base64encode(templatefile("${path.module}/../../scripts/init-vm.sh", {}))
}

# NIC Web
resource "azurerm_network_interface" "web" {
  count               = 2
  name                = "nic-web-${count.index}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids["web"]
    private_ip_address_allocation = "Dynamic"
  }
}

# VM DB
resource "azurerm_linux_virtual_machine" "db" {
  name                = "db-0-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size_db
  admin_username      = var.admin_user
  network_interface_ids = [azurerm_network_interface.db.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.admin_user
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# NIC DB
resource "azurerm_network_interface" "db" {
  name                = "nic-db-0-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids["db"]
    private_ip_address_allocation = "Dynamic"
  }
}
