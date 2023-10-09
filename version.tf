terraform {
  required_version = ">= 0.15, <1.6.0"

  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      version = ">= 1.17"
    }
  }
  experiments = [module_variable_optional_attrs]
}
