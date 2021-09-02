module "bastion" {
  source = "./module"

  resource_group_id = module.resource_group.id
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  vpc_name            = module.vpc.name
  vpc_subnet_count    = module.subnets.count
  vpc_subnets         = module.subnets.subnets
  ssh_key_id          = module.vpcssh.id
  allow_deprecated_image = false
  create_public_ip    = true
}

resource null_resource write_public_ip {
  provisioner "local-exec" {
    command = "echo '${module.bastion.private_ips[0]}' > .public-ip"
  }
}