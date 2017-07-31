output "bastion_public_ip" {
  value = "${module.bastion.bastion_public_ip}"
}

output "jenkins_endpoint" {
  value = "https://${module.asg.elb_dns_name}"
}

output "sonarqube_endpoint" {
  value = "http://${module.asg.elb_dns_name}:9000"
}

output "caddyserver_endpoint" {
  value = "http://${module.asg.elb_dns_name}:2015"
}

output "autoscaling_group_name" {
  value = "${module.asg.group_name}"
}