## Bastion Host

#### Inputs required

| Variable | Type | Description |
| --- | --- | --- |
| name | String | All resources are based on this. |
| bastion | Map | Configuration map for the bastion instance. |
| default_tags | Map | Default tags to add to resources. |

#### How to use

```HCL
module "bastion" {
  source = "../modules/bastion"
  name   = "${var.name}"

  bastion = {
    allowed_network = "${var.allowed_network}"
    vpc_id          = "${module.vpc.vpc_id}"
    instance_type   = "t2.nano"
    subnet_id       = "${module.vpc.public_subnets[0]}"
    key_name        = "${aws_key_pair.ssh.key_name}"
    ami             = "${data.aws_ami.ubuntu.id}"
  }

  default_tags = "${var.default_tags}"
}
```