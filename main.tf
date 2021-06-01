
locals {
  prefix_name = lower(replace(var.name_prefix != "" ? var.name_prefix : var.resource_group_name, "_", "-"))
  subnets     = data.ibm_is_subnet.vpc_subnet
  tags        = setsubtract(concat(var.tags, ["bastion"]), [""])
}

resource null_resource print-names {
  provisioner "local-exec" {
    command = "echo 'VPC name: ${var.vpc_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Resource group name: ${var.resource_group_name}'"
  }
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.print-names]

  name = var.resource_group_name
}

# get the information about the existing vpc instance
data ibm_is_vpc vpc {
  depends_on = [null_resource.print-names]

  name           = var.vpc_name
}

data ibm_is_subnet vpc_subnet {
  count = var.subnet_count

  identifier = var.subnets[count.index].id
}

resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# generate ssh key
resource ibm_is_ssh_key generated_key {
  name           = "${local.prefix_name}-${var.region}-key"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["vpc"])
}

output private_key {
  value = tls_private_key.ssh.private_key_pem
}

module "bastion" {
  source  = "we-work-in-the-cloud/vpc-bastion/ibm"
  version = "0.0.7"

  count = var.subnet_count

  name              = "${local.prefix_name}-bastion${format("%02s", count.index)}"
  resource_group_id = data.ibm_resource_group.resource_group.id
  vpc_id            = data.ibm_is_vpc.vpc.id
  subnet_id         = var.subnets[count.index].id
  ssh_key_ids       = [var.ssh_key_id]
  tags              = local.tags
  image_name        = "ibm-centos-8-3-minimal-amd64-3"
  profile_name      = "cx2-2x4"
  init_script       = file("${path.module}/scripts/init-jump-server.sh")
  create_public_ip  = var.create_public_ip
}

resource "null_resource" "harden_bastion" {
  count = var.subnet_count
  depends_on = [module.bastion.bastion_public_ip]
  connection {
    type        = "ssh"
    user        = "root"
    password    = ""
    private_key = tls_private_key.ssh.private_key_pem
    host        = module.bastion.bastion_public_ip
  }

provisioner "file" {
    source      = "${path.module}/scripts/pamscript.sh"
    destination = "/tmp/pamscript.sh"
  }

provisioner "file" {
    source      = "${path.module}/scripts/motd.txt"
    destination = "/tmp/motd.txt"
  }


provisioner "remote-exec" {
    inline     = [
      "chmod +x /tmp/pamscript.sh",
      "/tmp/pamscript.sh"
    ]
  }

}
