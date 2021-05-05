
locals {
  subnets     = data.ibm_is_subnet.vpc_subnet
  tags        = tolist(setsubtract(concat(var.tags, ["bastion"]), [""]))
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
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-vsi.git?ref=v1.2.2"

  resource_group_id    = var.resource_group_id
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  vpc_name             = var.vpc_name
  vpc_subnet_count     = var.vpc_subnet_count
  vpc_subnets          = var.vpc_subnets
  profile_name         = var.profile_name
  ssh_key_id           = var.ssh_key_id
  flow_log_cos_bucket_name = var.flow_log_cos_bucket_name
  kms_key_crn          = var.kms_key_crn
  kms_enabled          = var.kms_enabled
  init_script          = file("${path.module}/scripts/init-jump-server.sh")
  create_public_ip     = var.create_public_ip
  allow_ssh_from       = var.allow_ssh_from
  tags                 = local.tags
  security_group_rules = var.security_group_rules
  label                = var.label
}
