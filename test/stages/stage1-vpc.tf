module "vpc" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc.git"

  resource_group_name = module.resource_group.name
  region              = var.region
  #name_prefix         = var.name_prefix
  name_prefix = "${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length           = 16
  special          = true
  override_special = "/@£"
  # Only Alpha numeric - dont pass special $ 
}