## AWS AutoScaling Group

#### Inputs required

| Variable | Type | Description |
| --- | --- | --- |
| name | String | All resources are based on this. |
| lc | Map | Configuration map for ASG LaunchConfig. |
| elb | Map | Configuration map for ASG ELB. |
| asg | Map | Configuration map for ASG. |
| default_tags | Map | Default tags to add to resources. |

#### How to use

```HCL
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

```