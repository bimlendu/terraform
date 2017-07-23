variable "aws_profile" {}
variable "region" {}

variable "name" {}

variable "allowed_network" {}

variable "jenkins_version" {}
variable "jenkins_instance_type" {}
variable "jenkins_admin_password" {}
variable "jenkins_admin_username" {}
variable "jenkins_plugins" {}

variable "golang_version" {}

variable "sonarqube_version" {}
variable "sonarqube_db_name" {}
variable "sonarqube_db_user" {}
variable "sonarqube_db_password" {}
variable "sonarqube_server_url" {}

variable "sonar_scanner_version" {}

variable "ansible_repo" {}

variable "ssh_public_key" {}

variable "msg_provider_dest_phone" {}
variable "msg_provider_src_phone" {}
variable "msg_provider_auth_token" {}
variable "msg_provider_auth_id" {}

variable "caddy_pipeline_repo" {}
variable "caddy_pipeline_job" {}
variable "caddy_pipeline_file" {}

variable "statuspage_api_key" {}

variable "default_tags" {
  type = "map"
}
