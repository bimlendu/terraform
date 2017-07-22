data "aws_iam_server_certificate" "lb" {
  name_prefix = "${lookup(var.elb, "ssl_certificate_prefix")}"
  latest      = true
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "asg" {
  key_name_prefix = "${var.name}-"
  public_key      = "${lookup(var.lc, "ssh_public_key")}"
}

resource "aws_security_group" "lb" {
  name_prefix = "${var.name}-lb-sg-"
  description = "Allow http(s) access from var.allowed_networks."
  vpc_id      = "${lookup(var.asg, "vpc_id")}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.elb, "allowed_network")}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.elb, "allowed_network")}"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.elb, "allowed_network")}"]
  }

  ingress {
    from_port   = 2015
    to_port     = 2015
    protocol    = "tcp"
    cidr_blocks = ["${lookup(var.elb, "allowed_network")}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-lb-sg", var.name)
  ))}"
}

resource "aws_elb" "lb" {
  name = "${var.name}-lb"

  subnets         = ["${split(",", lookup(var.elb, "subnets"))}"]
  internal        = "${lookup(var.elb, "internal")}"
  security_groups = ["${aws_security_group.lb.id}"]

  listener {
    instance_port      = "${lookup(var.elb, "instance_port")}"
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_iam_server_certificate.lb.arn}"
  }

  listener {
    instance_port     = 9000
    instance_protocol = "http"
    lb_port           = 9000
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 2015
    instance_protocol = "http"
    lb_port           = 2015
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 4
    target              = "TCP:${lookup(var.elb, "instance_port")}"
    interval            = 30
  }

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-lb", var.name)
  ))}"
}

resource "aws_launch_configuration" "lc" {
  name_prefix          = "${var.name}-lc-"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "${lookup(var.lc, "instance_type")}"
  key_name             = "${aws_key_pair.asg.key_name}"
  security_groups      = ["${lookup(var.lc, "security_groups")}"]
  user_data            = "${lookup(var.lc, "user_data")}"
  iam_instance_profile = "${lookup(var.lc, "iam_instance_profile")}"

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on = ["aws_launch_configuration.lc"]

  name_prefix      = "${var.name}-asg-"
  max_size         = "${lookup(var.asg, "max_size")}"
  min_size         = "${lookup(var.asg, "min_size")}"
  desired_capacity = "${lookup(var.asg, "desired_capacity")}"

  launch_configuration = "${aws_launch_configuration.lc.id}"

  health_check_type         = "${lookup(var.asg, "health_check_type")}"
  health_check_grace_period = "${lookup(var.asg, "health_check_grace_period")}"

  load_balancers = ["${aws_elb.lb.id}"]

  vpc_zone_identifier = ["${split(",", lookup(var.asg, "subnets"))}"]
}
