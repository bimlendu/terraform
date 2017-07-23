## AWS VPC

#### Inputs required

| Variable | Type | Description |
| --- | --- | --- |
| name | String | All resources are based on this. |
| vpc | Map | Configuration map for vpc. |
| default_tags | Map | Default tags to add to resources. |

#### How to use

```HCL
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
```

*spread_across* ensures the vpc subnets are spread-across these many number of availanility zones in the region.