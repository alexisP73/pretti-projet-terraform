# NSG Web
resource "azurerm_network_security_group" "web" {
  name                = "web-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = {
      ssh = { port = 22, prio = 100 },
      http = { port = 80, prio = 110 }
    }
    content {
      name                       = "allow-${security_rule.key}"
      priority                   = security_rule.value.prio
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = security_rule.value.port
      destination_address_prefix = "*"
    }
  }
}

# NSG DB
resource "azurerm_network_security_group" "db" {
  name                = "db-nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = { ssh = { port = 22, prio = 100 } }
    content {
      name                       = "allow-ssh-from-web"
      priority                   = security_rule.value.prio
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = var.web_subnet_id
      destination_port_range     = security_rule.value.port
      destination_address_prefix = "*"
    }
  }
}

# Associer NSG aux subnets
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db.id
}
