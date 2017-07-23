resource "aws_security_group" "jenkins" {
  name_prefix = "${var.name}-jenkins-sg-"
  description = "Base security group to be added to jenkins."
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-jenkins-sg", var.name)
  ))}"
}

resource "aws_security_group_rule" "jenkins_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${module.bastion.security_group_id}"
  security_group_id        = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group_rule" "jenkins_http" {
  type                     = "ingress"
  from_port                = "${module.asg.instance_service_port}"
  to_port                  = "${module.asg.instance_service_port}"
  protocol                 = "tcp"
  source_security_group_id = "${module.asg.lb_security_group_id}"
  security_group_id        = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group_rule" "sonar_http" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  source_security_group_id = "${module.asg.lb_security_group_id}"
  security_group_id        = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group_rule" "caddy_http" {
  type                     = "ingress"
  from_port                = 2015
  to_port                  = 2015
  protocol                 = "tcp"
  source_security_group_id = "${module.asg.lb_security_group_id}"
  security_group_id        = "${aws_security_group.jenkins.id}"
}
