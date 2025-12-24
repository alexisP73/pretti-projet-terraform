variable "resource_group_name" { type = string }
variable "location" {
    type = string
    default = "francecentral"
}
variable "vnet_name" { type = string }
variable "vnet_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "subnets" {
    type = map(string)
    default = {}
}
