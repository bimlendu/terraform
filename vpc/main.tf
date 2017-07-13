# get all available zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# create the vpc
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

# add an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-igw", var.name)
  ))}"
}

# add public subnets in each available zones, limited by ${var.num_zones}
resource "aws_subnet" "public" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names)))), 2)), count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  map_public_ip_on_launch = true

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-public-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

# add private subnets in each available zones, limited by ${var.num_zones}
resource "aws_subnet" "private" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"

  vpc_id = "${aws_vpc.default.id}"

  cidr_block        = "${cidrsubnet(lookup(var.vpc, "cidr_block"), ceil(log(2 * length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names)))), 2)), count.index + length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names)))))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = "${merge(var.default_tags, map(
    "Name", format("%s-private-%s", var.name, element(data.aws_availability_zones.available.names, count.index))
  ))}"
}

# add public route table and its route association
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

# allocate EIPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count    = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  vpc = true
}

# allocate nat gateways per private subnet
resource "aws_nat_gateway" "nat_gw" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.igw"]
}

# for each private subnet, create a private route table.
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  tags             = "${merge(var.default_tags, map(
    "Name", format("%s-rt-private-%s", var.name, count.index)
  ))}"
}

# add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.private"]
  nat_gateway_id = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}

# associate private route tables and subnets
resource "aws_route_table_association" "private" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# associate public route table and subnets
resource "aws_route_table_association" "public" {
  count = "${length(slice(data.aws_availability_zones.available.names,0,min(lookup(var.vpc, "spread_across"), length(data.aws_availability_zones.available.names))))}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

