variable "resource_group_name" {
  type    = string
  default = "k3s-rg"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}