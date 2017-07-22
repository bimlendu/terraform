output "elb_dns_name" {
  value = "${aws_elb.lb.dns_name}"
}

output "instance_service_port" {
  value = "${lookup(var.elb, "instance_port")}"
}

output "lb_security_group_id" {
  value = "${aws_security_group.lb.id}"
}

output "group_name" {
  value = "${aws_autoscaling_group.asg.name}"
}