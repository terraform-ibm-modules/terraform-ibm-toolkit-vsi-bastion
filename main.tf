provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
}

data ibm_resource_group group {
  name = var.resource_group_name
}

locals {
  ssh_key_ids    = [ibm_is_ssh_key.generated_key.id]
  subnets        = data.ibm_is_vpc.vpc.subnets
  bastion_subnet = local.subnets.0
  instances      = module.vsi-instance.0.instances
}

resource null_resource print-vpc_name {
  provisioner "local-exec" {
    command = "echo ${var.vpc_name}"
  }
}

# get the information about the existing vpc instance
data ibm_is_vpc vpc {
  depends_on = [null_resource.print-vpc_name]

  name           = var.vpc_name
}

resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# generate ssh key
resource ibm_is_ssh_key generated_key {
  name           = "${var.name_prefix}-${var.region}-key"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = data.ibm_resource_group.group.id
  tags           = concat(var.tags, ["vpc"])
}

# create the vsi instance
module vsi-instance {
  source = "./vsi-instance"

  name              = "${var.name_prefix}-bastion-instance"
  resource_group_id = data.ibm_resource_group.group.id
  vpc_id            = data.ibm_is_vpc.vpc.id
  vpc_subnets       = local.subnets
  ssh_key_ids       = local.ssh_key_ids
  tags              = concat(var.tags, ["instance"])
}

module "bastion" {
  source  = "we-work-in-the-cloud/vpc-bastion/ibm"
  version = "0.0.5"

  name              = "${var.name_prefix}-bastion"
  resource_group_id = data.ibm_resource_group.group.id
  vpc_id            = data.ibm_is_vpc.vpc.id
  subnet_id         = local.bastion_subnet.id
  ssh_key_ids       = local.ssh_key_ids
  tags              = concat(var.tags, ["bastion"])
}

# open the VPN port on the bastion
resource ibm_is_security_group_rule vpn {
  group     = module.bastion.bastion_security_group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 65000
    port_max = 65000
  }
}

#
# Allow all hosts created by this script to be accessible by the bastion
#
resource "ibm_is_security_group_network_interface_attachment" "under_maintenance" {
  count = length(module.vsi-instance.0.instances)

  network_interface = module.vsi-instance.0.instances[count.index].primary_network_interface.0.id
  security_group    = module.bastion.bastion_maintenance_group_id
}

#
# Ansible playbook to install OpenVPN
#
module ansible {
  source = "./ansible"

  bastion_ip             = module.bastion.bastion_public_ip
  instances              = local.instances
  subnets                = local.subnets
  private_key_pem        = tls_private_key.ssh.private_key_pem
  openvpn_server_network = var.openvpn_server_network
}
