output "mount_target_endpoints" {
  value = "${aws_efs_mount_target.efs.*.dns_name[0]}"
}
