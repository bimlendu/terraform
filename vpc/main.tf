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
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(slice(data.aws_availability_zones.available.names,0,2)), 2)), count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  map_public_ip_on_launch = true

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-public-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

resource "aws_subnet" "private" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(slice(data.aws_availability_zones.available.names,0,2)), 2)), count.index + length(slice(data.aws_availability_zones.available.names,0,2)))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-private-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.default.id}"
  tags             = "${merge(var.default_tags, map(
    "Name", format("%s-rt-public", var.name)
  ))}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_eip" "nat_eip" {
  count    = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.igw"]
}

# for each of the private ranges, create a "private" route table.
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  tags             = "${merge(var.default_tags, map(
    "Name", format("%s-rt-private-%s", var.name, count.index)
  ))}"
}

# add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.private"]
  nat_gateway_id = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,2))}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

