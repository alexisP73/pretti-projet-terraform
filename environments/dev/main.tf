terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "remote" {
    organization = "cloudtech-solutions"  # ← À modifier !
    workspaces {
      name = "pretti-projet-terraform-dev"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_storage_account" "diagnostics" {
  name                     = "${var.prefix}${var.environment}diag"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = "${var.prefix}-${var.environment}-vnet"
  subnets = {
    web = "10.0.1.0/24"
    db  = "10.0.2.0/24"
  }
}

module "security" {
  source              = "../../modules/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  web_subnet_id       = module.network.subnet_ids["web"]
  db_subnet_id        = module.network.subnet_ids["db"]
  environment         = var.environment
}

module "compute" {
  source              = "../../modules/compute"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  subnet_ids          = module.network.subnet_ids
  environment         = var.environment
  admin_user          = var.admin_user
  ssh_public_key      = var.ssh_public_key
  vm_size_web         = var.environment == "prod" ? "Standard_B2s" : "Standard_B1s"
  vm_size_db          = var.environment == "prod" ? "Standard_B2s" : "Standard_B1s"
}

# Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "lb-pip-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "main" {
  name                = "lb-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "web-pool"
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/"
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = 2
  network_interface_id    = module.compute.web_vm_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
}
