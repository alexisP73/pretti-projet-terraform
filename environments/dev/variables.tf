variable "prefix" { default = "myapp" }
variable "environment" { default = "dev" }
variable "location" { default = "francecentral" }
variable "admin_user" { default = "azureuser" }
variable "ssh_public_key" {
  description = "Clé SSH publique injectée depuis Terraform Cloud"
  type        = string
}
