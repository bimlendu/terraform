resource "aws_s3_bucket" "caddy_deploy" {
  bucket = "${var.name}-caddy-deploy"
  acl    = "private"

  tags = "${merge(var.default_tags, map( "Name","${var.name}-caddy-deploy" ))}"

  force_destroy = true

  lifecycle {
    create_before_destroy = true
  }
}
