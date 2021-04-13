module "bastion" {
  source = "./module"

  resource_group_id = module.resource_group.id
  region            = var.region
  name_prefix       = var.name_prefix
  ibmcloud_api_key  = var.ibmcloud_api_key
  vpc_name          = module.vpc.name
  subnet_count      = module.subnets.subnet_count
  subnets           = module.subnets.subnets
  ssh_key_id        = module.vpcssh.id
}
