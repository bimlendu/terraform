module "vpc" {
  source = "../modules/vpc"
  name   = "${var.name}"

  vpc = {
    cidr_block                       = "10.0.0.0/24"
    instance_tenancy                 = "default"
    enable_dns_support               = true
    enable_dns_hostnames             = true
    enable_classiclink               = false
    assign_generated_ipv6_cidr_block = false
    spread_across                    = 2
  }

  default_tags = "${var.default_tags}"
}
