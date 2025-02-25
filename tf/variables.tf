variable "ssh_public_key_file" {
  type = string
}

variable "linode_pat" {
  type = string
  sensitive = true
}

variable "porkbun_api_key" {
  type = string
  sensitive = true
}

variable "porkbun_secret_key" {
  type = string
  sensitive = true
}

