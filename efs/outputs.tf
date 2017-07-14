output "mount_target_endpoints" {
  value = "${aws_efs_mount_target.efs.*.dns_name[0]}"
}

output "efs_clients_security_group_id" {
  value = "${aws_security_group.efs-clients.id}"
}
