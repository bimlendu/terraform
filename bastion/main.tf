data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow ssh access to bastion from var.allowed_networks."
  vpc_id      = "${lookup(var.bastion, "vpc_id")}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.bastion, "allowed_network")}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-bastion-sg", var.name)
  ))}"
}

resource "aws_security_group" "internal_ssh" {
  name        = "internal-ssh"
  description = "Allow ssh from bastion."
  vpc_id      = "${lookup(var.bastion, "vpc_id")}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-internal-ssh-sg", var.name)
  ))}"
}

resource "aws_key_pair" "bastion" {
  key_name_prefix = "bastion-"
  public_key      = "${lookup(var.bastion, "ssh_public_key")}"
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.bastion.id}"
  instance_type          = "${lookup(var.bastion, "instance_type")}"
  key_name               = "${aws_key_pair.bastion.key_name}"
  subnet_id              = "${lookup(var.bastion, "subnet_id")}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-bastion", var.name)
  ))}"
}
