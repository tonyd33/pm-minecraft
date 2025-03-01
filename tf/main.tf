resource "linode_sshkey" "minecraft" {
  label   = "minecraft"
  ssh_key = chomp(file(var.ssh_public_key_file))
}

resource "linode_vpc" "minecraft" {
  label = "minecraft"
  region = var.region
}

resource "linode_vpc_subnet" "minecraft" {
  vpc_id = linode_vpc.minecraft.id
  label = "minecraft"
  ipv4 = "172.16.55.0/24"
}

resource "linode_instance" "swarm_manager" {
  count = var.manager_count
  image           = "linode/ubuntu24.04"
  label           = "swarm-manager-${format("%02s", count.index + 1)}"
  region          = var.region
  type            = var.manager_type
  tags = ["pumpkinmouse", "minecraft", "swarm-manager"]
  authorized_keys = [linode_sshkey.minecraft.ssh_key]

  interface {
    purpose = "public"
  }

  interface {
    purpose = "vpc"
    subnet_id = linode_vpc_subnet.minecraft.id
    ipv4 {
      vpc = "${cidrhost(linode_vpc_subnet.minecraft.ipv4, count.index + 32)}"
    }
  }
}

resource "linode_instance" "swarm_worker" {
  count = var.worker_count
  image           = "linode/ubuntu24.04"
  label           = "swarm-worker-${format("%02s", count.index + 1)}"
  region          = var.region
  type            = var.worker_type
  tags = ["pumpkinmouse", "minecraft", "swarm-worker"]
  authorized_keys = [linode_sshkey.minecraft.ssh_key]

  interface {
    purpose = "public"
  }

  interface {
    purpose = "vpc"
    subnet_id = linode_vpc_subnet.minecraft.id
    ipv4 {
      vpc = "${cidrhost(linode_vpc_subnet.minecraft.ipv4, count.index + 64)}"
    }
  }
}

resource "porkbun_dns_record" "swarm_manager" {
  count = var.manager_count
  domain = var.domain
  type = "A"
  name = "${linode_instance.swarm_manager[count.index].label}.pm"
  content = linode_instance.swarm_manager[count.index].ip_address
}

resource "porkbun_dns_record" "swarm_worker" {
  count = var.worker_count
  domain = var.domain
  type = "A"
  name = "${linode_instance.swarm_worker[count.index].label}.pm"
  content = linode_instance.swarm_worker[count.index].ip_address
}

resource "ansible_group" "swarm" {
  name = "swarm"
  children = ["swarm_manager", "swarm_worker"]
  variables = {
    vpc_subnet = linode_vpc_subnet.minecraft.ipv4
    ansible_user = "root"
  }
}

resource "ansible_host" "swarm_manager" {
  count = var.manager_count
  name = "${porkbun_dns_record.swarm_manager[count.index].name}.${var.domain}"
  groups = ["swarm_manager", "minecraft"]
}

resource "ansible_host" "swarm_worker" {
  count = var.worker_count
  name = "${porkbun_dns_record.swarm_worker[count.index].name}.${var.domain}"
  groups = ["swarm_worker"]
}
