resource "aws_codedeploy_app" "app" {
  name = "${var.name}-code-deploy-app"
}

resource "aws_codedeploy_deployment_group" "app_group" {
  app_name               = "${aws_codedeploy_app.app.name}"
  deployment_group_name  = "${var.name}-deploy-group"
  service_role_arn       = "${aws_iam_role.codedeploy_service_role.arn}"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_filter {
    key   = "aws:autoscaling:groupName"
    type  = "KEY_AND_VALUE"
    value = "${module.asg.group_name}"
  }
}
