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

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-bastion-sg"))}"
}

resource "aws_instance" "bastion" {
  ami                    = "${lookup(var.bastion, "ami")}"
  instance_type          = "${lookup(var.bastion, "instance_type")}"
  key_name               = "${lookup(var.bastion, "key_name")}"
  subnet_id              = "${lookup(var.bastion, "subnet_id")}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags = "${merge(var.default_tags, map( "Name", "${var.name}-bastion"))}"
}
