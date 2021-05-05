output "ids" {
  description = "The instance ids"
  value       = module.vsi-instance.ids
}

output vpc_name {
  value = data.ibm_is_vpc.vpc.name
}

output instance_count {
  value = var.vpc_subnet_count
}

output public_ips {
  value = module.vsi-instance.public_ips
}

output private_ips {
  value = module.vsi-instance.private_ips
}

output network_interface_ids {
  value = module.vsi-instance.network_interface_ids
}

output "security_group_id" {
  description = "The id of the security group that was created"
  value       = module.vsi-instance.security_group_id
}

output "security_group" {
  description = "The security group that was created"
  value       = module.vsi-instance.security_group
}

output "maintenance_security_group_id" {
  description = "The id of the security group that was created"
  value       = ibm_is_security_group.maintenance.id
}

output "maintenance_security_group" {
  description = "The security group that was created"
  value       = ibm_is_security_group.maintenance
}