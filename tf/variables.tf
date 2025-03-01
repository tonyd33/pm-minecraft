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

variable "domain" {
  type = string
}

variable "manager_count" {
  type = number
}

variable "manager_type" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "worker_type" {
  type = string
}

variable "region" {
  type = string
  default = "us-sea"
}
