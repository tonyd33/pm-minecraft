terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    linode = {
      source  = "linode/linode"
      version = "2.34.1"
    }
    porkbun = {
      source = "cullenmcdermott/porkbun"
      version = "0.3.0"
    }
  }
}

provider "porkbun" {
  api_key = var.porkbun_api_key
  secret_key = var.porkbun_secret_key
}

provider "linode" {
  token = var.linode_pat
}
