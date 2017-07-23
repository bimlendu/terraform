module "efs" {
  source                 = "../modules/efs"
  name                   = "${var.name}-efs"
  vpc_id                 = "${module.vpc.vpc_id}"
  subnets                = "${module.vpc.private_subnets}"
  default_tags           = "${var.default_tags}"
  source_security_groups = "${aws_security_group.jenkins.id}"
}
