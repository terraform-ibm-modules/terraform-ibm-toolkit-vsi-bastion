
locals {
  subnets     = data.ibm_is_subnet.vpc_subnet
  tags        = tolist(setsubtract(concat(var.tags, ["bastion"]), [""]))
  name        = "${replace(var.vpc_name, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${var.label}"
}

resource null_resource print-names {
  provisioner "local-exec" {
    command = "echo 'VPC name: ${var.vpc_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Resource group id: ${var.resource_group_id}'"
  }
}

# get the information about the existing vpc instance
data ibm_is_vpc vpc {
  depends_on = [null_resource.print-names]

  name           = var.vpc_name
}

data ibm_is_subnet vpc_subnet {
  count = var.vpc_subnet_count

  identifier = var.vpc_subnets[count.index].id
}

module "vsi-instance" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-vsi.git?ref=v1.6.0"

  resource_group_id    = var.resource_group_id
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  vpc_name             = var.vpc_name
  vpc_subnet_count     = var.vpc_subnet_count
  vpc_subnets          = var.vpc_subnets
  image_name           = var.image_name
  profile_name         = var.profile_name
  ssh_key_id           = var.ssh_key_id
  kms_key_crn          = var.kms_key_crn
  kms_enabled          = var.kms_enabled
  init_script          = file("${path.module}/scripts/init-jump-server.sh")
  create_public_ip     = var.create_public_ip
  allow_ssh_from       = var.allow_ssh_from
  tags                 = local.tags
  security_group_rules = var.security_group_rules
  label                = var.label
  allow_deprecated_image = var.allow_deprecated_image
  base_security_group  = var.base_security_group
}

resource ibm_is_security_group maintenance {
  name           = "${local.name}-maintenance"
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource ibm_is_security_group_rule ssh_to_host_in_maintenance {
  group     = module.vsi-instance.security_group_id
  direction = "outbound"
  remote    = ibm_is_security_group.maintenance.id
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource ibm_is_security_group_rule maintenance_ssh_inbound {
  group     = ibm_is_security_group.maintenance.id
  direction = "inbound"
  remote    = module.vsi-instance.security_group_id
  tcp {
    port_min = 22
    port_max = 22
  }
}
