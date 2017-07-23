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
