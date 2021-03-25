# VSI Bastion module

Terraform module to provision VSI instances on an existing VPC server and install Bastion into the VSI server.

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v12

### Terraform providers

- IBM Cloud provider >= 1.5.3

## Module dependencies

This module makes use of the output from other modules:

- VPC - github.com/cloud-native-toolkit/terraform-ibm-vpc

## Example usage

```hcl-terraform
module "bastion" {
  source = "github.com/cloud-native-toolkit/terraform-vsi-bastion.git?ref=v1.0.0"

  resource_group_name = var.resource_group_name
  region              = var.region
  name_prefix         = var.name_prefix
  ibmcloud_api_key    = var.ibmcloud_api_key
  vpc_name            = module.vpc.name}
```

