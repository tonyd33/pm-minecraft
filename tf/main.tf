resource "linode_sshkey" "mc" {
  label   = "mc"
  ssh_key = chomp(file(var.ssh_public_key_file))
}

resource "linode_instance" "mc_velocity" {
  image           = "linode/ubuntu24.04"
  label           = "mc-velocity"
  region          = "us-sea"
  type            = "g6-standard-2"
  authorized_keys = [linode_sshkey.mc.ssh_key]
}

locals {
  extra_domains = [
    "lobby.mc.pm",
    "factions.mc.pm",
    "minigames.mc.pm",
  ]
}

resource "porkbun_dns_record" "mc_velocity" {
  domain = "gnomes.moe"
  type = "A"
  name = "velocity.pm"
  content = linode_instance.mc_velocity.ip_address
}

# These should probably be CNAMEs but w/e
resource "porkbun_dns_record" "mc_extra_domains" {
  for_each = toset(local.extra_domains)
  domain = "gnomes.moe"
  type = "A"
  name = each.key
  content = linode_instance.mc_velocity.ip_address
}
