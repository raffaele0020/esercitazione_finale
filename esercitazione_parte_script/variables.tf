variable "resource_group_name" {
  type    = string
  default = "test-sh"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "admin_username" {
  type    = string
  default = "raffaeleuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
  # Non includere un default per password sensibili
}

variable "ssh_public_key_path" {
  type    = string
  default = "C:/Users/tufan/.ssh/id_rsa.pub"
}