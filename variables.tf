variable "resource_group_name" {
  type        = string
  description = "The name of the IBM Cloud resource group where the Bastion instance will be created."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
}

variable "name_prefix" {
  type        = string
  description = "The name of the vpc resource"
  default     = ""
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

variable "tags" {
  type        = list(string)
  description = "List of tags"
  default     = []
}

variable "vpc_name" {
  type        = string
  description = "The name of the existing VPC instance"
}

variable "subnet_count" {
  type        = number
  description = "The number of subnets on the vpc instance"
}

variable "subnets" {
  type        = list(object({id = string, zone = string, label = string}))
  description = "The list of subnet objects where bastion servers will be provisioned"
}

variable "ssh_key_id" {
  type        = string
  description = "The id of a key registered with the VPC"
}

variable "create_public_ip" {
  type        = bool
  default     = false
  description = "Flag to create a public ip address on the bastion instance"
}
