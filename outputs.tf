output vpc_name {
  value = data.ibm_is_vpc.vpc.name
}

output instance_count {
  value = var.subnet_count
}

output public_ips {
  value = module.bastion[*].bastion_public_ip
}

output private_ips {
  value = module.bastion[*].bastion_private_ip
}

output network_interface_ids {
  value = module.bastion[*].bastion_network_interface_ids[0]
}
