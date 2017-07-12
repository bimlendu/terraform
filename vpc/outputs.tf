output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.default.cidr_block}"
}

output "vpc_igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}
