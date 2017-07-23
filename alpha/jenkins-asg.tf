data "template_file" "user_data_jenkins" {
  template = "${file("user_data_jenkins.tpl")}"

  vars {
    jenkins_version         = "${var.jenkins_version}"
    jenkins_admin_username  = "${var.jenkins_admin_username}"
    jenkins_admin_password  = "${var.jenkins_admin_password}"
    jenkins_plugins         = "${var.jenkins_plugins}"
    golang_version          = "${var.golang_version}"
    efs_filesystem_dns      = "${module.efs.mount_target_endpoints}"
    ansible_repo            = "${var.ansible_repo}"
    sonarqube_db_host       = "${module.postgresql.db_instance}"
    sonarqube_db_name       = "${var.sonarqube_db_name}"
    sonarqube_db_user       = "${var.sonarqube_db_user}"
    sonarqube_db_password   = "${var.sonarqube_db_password}"
    sonarqube_version       = "${var.sonarqube_version}"
    sonarqube_server_url    = "${var.sonarqube_server_url}"
    sonar_scanner_version   = "${var.sonar_scanner_version}"
    caddy_pipeline_job      = "${var.caddy_pipeline_job}"
    caddy_pipeline_repo     = "${var.caddy_pipeline_repo}"
    caddy_pipeline_file     = "${var.caddy_pipeline_file}"
    msg_provider_auth_id    = "${var.msg_provider_auth_id}"
    msg_provider_auth_token = "${var.msg_provider_auth_token}"
    msg_provider_src_phone  = "${var.msg_provider_src_phone}"
    msg_provider_dest_phone = "${var.msg_provider_dest_phone}"
    statuspage_api_key      = "${var.statuspage_api_key}"
  }
}

module "asg" {
  source       = "../modules/asg"
  name         = "${var.name}-jenkins-asg"
  default_tags = "${var.default_tags}"

  lc = {
    instance_type        = "${var.jenkins_instance_type}"
    security_groups      = "${aws_security_group.jenkins.id}"
    user_data            = "${data.template_file.user_data_jenkins.rendered}"
    iam_instance_profile = "${aws_iam_instance_profile.jenkins.id}"
    key_name             = "${aws_key_pair.ssh.key_name}"
    ami                  = "${data.aws_ami.ubuntu.id}"
  }

  asg = {
    vpc_id                    = "${module.vpc.vpc_id}"
    max_size                  = 1
    min_size                  = 1
    desired_capacity          = 1
    health_check_type         = "EC2"
    health_check_grace_period = 600
    subnets                   = "${join(",", module.vpc.private_subnets)}"
    service_port              = 8080
  }

  elb = {
    allowed_network = "${var.allowed_network}"
    internal        = false
    instance_port   = 8080
    subnets         = "${join(",", module.vpc.public_subnets)}"
  }
}
