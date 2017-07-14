output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

output "internal_ssh_security_group" {
  value = "${aws_security_group.internal_ssh.id}"
}
