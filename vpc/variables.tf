variable "name" {}

variable "vpc" {
  type        = "map"
  description = "All vpc properties in a map"

  default = {
    cidr_block                       = "10.0.0.0/8"
    instance_tenancy                 = "default"
    enable_dns_support               = true
    enable_dns_hostnames             = true
    enable_classiclink               = false
    assign_generated_ipv6_cidr_block = false
  }
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to add to resources."
}
