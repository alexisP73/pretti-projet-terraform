variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_ids" { type = map(string) }
variable "admin_user" {
    type = string
    default = "azureuser"
}
variable "environment" { type = string }
variable "vm_size_web" {
    type = string
    default = "Standard_B1s"
}
variable "vm_size_db" {
    type = string
    default = "Standard_B2s"
}
