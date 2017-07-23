resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.name}-jenkins-profile"
  role = "${aws_iam_role.jenkins.name}"
}

resource "aws_iam_role" "jenkins" {
  name = "${var.name}-jenkins-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
         "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_bucket_access" {
  name = "${var.name}-codedeploy-bucket-access"
  role = "${aws_iam_role.jenkins.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.caddy_deploy.id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.caddy_deploy.id}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "aws_codedeploy_buckets_access" {
  name = "${var.name}-aws-codedeploy-bucket-access"
  role = "${aws_iam_role.jenkins.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::aws-codedeploy-${var.region}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodeDeployDeployerPolicy" {
  role       = "${aws_iam_role.jenkins.id}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
}
