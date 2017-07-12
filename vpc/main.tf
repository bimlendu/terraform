data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block                       = "${lookup(var.vpc, "cidr_block")}"
  instance_tenancy                 = "${lookup(var.vpc, "instance_tenancy")}"
  enable_dns_support               = "${lookup(var.vpc, "enable_dns_support")}"
  enable_dns_hostnames             = "${lookup(var.vpc, "enable_dns_hostnames")}"
  enable_classiclink               = "${lookup(var.vpc, "enable_classiclink")}"
  assign_generated_ipv6_cidr_block = "${lookup(var.vpc, "assign_generated_ipv6_cidr_block")}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-vpc", var.name)
  ))}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-igw", var.name)
  ))}"
}

resource "aws_subnet" "public" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(data.aws_availability_zones.available.names), 2)), count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  map_public_ip_on_launch = true

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-public-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

resource "aws_subnet" "private" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(data.aws_availability_zones.available.names), 2)), count.index + length(data.aws_availability_zones.available.names))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-private-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

