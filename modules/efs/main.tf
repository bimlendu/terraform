resource "random_id" "creation_token" {
  byte_length = 8
  prefix      = "${var.name}-"
}

resource "aws_efs_file_system" "efs" {
  creation_token   = "${random_id.creation_token.hex}"
  performance_mode = "generalPurpose"

  tags = "${merge(var.default_tags, map( "Name", "${var.name}"))}"
}

resource "aws_efs_mount_target" "efs" {
  count = "${length(var.subnets)}"

  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${element(var.subnets, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name_prefix = "efs-"
  description = "Security Group of EFS filesystem."
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-sg"))}"
}

resource "aws_security_group_rule" "allow-efs-clients" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.efs.id}"
  source_security_group_id = "${var.source_security_groups}"
}
