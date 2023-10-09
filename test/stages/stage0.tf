terraform {
  required_version = ">= 0.13, <1.6.0"

  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
}

locals {
  name_prefix = "ee-${random_string.name-prefix.result}"
}

resource "random_string" "name-prefix" {
  length           = 16
  special          = false
  upper = false
  override_special = "/*$"
}

