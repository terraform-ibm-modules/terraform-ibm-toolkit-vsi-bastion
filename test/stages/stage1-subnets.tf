module "subnets" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-subnets.git"

  resource_group_name = module.resource_group.name
  region              = var.region
  vpc_name            = module.vpc.name
  gateways            = module.gateways.gateways
  _count              = 1
  label               = "bastion"
  acl_rules           = [{
    name="inbound-ssh"
    action="allow"
    direction="inbound"
    source="0.0.0.0/0"
    destination="0.0.0.0/0"
  }]
}
