module "vpcssh" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-ssh.git"

  resource_group_name = module.resource_group.name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
  public_key          = ""
  private_key         = ""
}

resource null_resource write_private_key {
  provisioner "local-exec" {
    command = "echo '${module.vpcssh.private_key}' > .private-key && chmod 700 .private-key"
  }
}
