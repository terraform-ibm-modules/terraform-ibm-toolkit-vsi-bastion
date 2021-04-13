output vpc_name {
  value = data.ibm_is_vpc.vpc.name
}

output bastion_ips {
  value = module.bastion[*].bastion_public_ip
}

output bastion_private_ips {
  value = module.bastion[*].bastion_private_ip
}
