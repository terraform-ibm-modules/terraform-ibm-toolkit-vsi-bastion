
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
  init_script       = file("${path.module}/scripts/init-jump-server.sh")
  create_public_ip  = var.create_public_ip
}
