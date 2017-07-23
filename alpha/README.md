## Alpha

This project creates following resources:

* A vpc with the given CIDR. Private and public subnets. Route tables, NAT gateways IGW and other VPC resources.
* A bastion host with security group allowing access from specified network.
* An autoscaling group, with min-max set to 1. A public ELB , with access restricted to specified network.
* An EFS filesystem to be used with asg instance(s).
* A postgresql rds db.
* A self signed certificate is also generated to use with the ELB.
* IAM roles for access.
* Security groups with minimal access everywhere.
* A CodeDeploy app and deploy group.
* An S3 bucket to store codedeploy zips.
* Instances are configured by ansible repo provided by `ansible_repo` variable.

#### Inputs required

| Variable | Type | Description |
| --- | --- | --- |
| aws_profile | String | Local AWS profile to use. |
| region | String | AWS region to launch resources in. |
| name | String | All resources are based on this. |
| allowed_network | String | Allow access from this network. Your public IP for eg. |
| jenkins_version | String | Jenkins version to install. |
| jenkins_instance_type | String | Jenkins instance type. |
| jenkins_admin_username | String | Jenkins admin user to create. |
| jenkins_plugins | String | Password for jenkins admin user. |
| golang_version | String | Golang plugin version to install in Jenkins. |
| sonarqube_version | String | Sonrqube version to install. |
| sonarqube_db_name | String | Sonarqube DB name. |
| sonarqube_db_user | String | Sonarqube DB user. |
| sonarqube_db_password | String | Sonarqube DB password. |
| sonarqube_server_url | String | Sonarqube server url. (http://localhost:9000 if both jenkins and sonar are on the same instance.) |
| sonar_scanner_version | String | SonarScanner version to install in jenkins. |
| ansible_repo | String | Ansible repo to use to configure instances. Should be public. |
| ssh_public_key | String | Path to a local ssh public key. |
| msg_provider_auth_id | String | Msg provider auth id. |
| msg_provider_auth_token | String | Msg provider auth token. |
| msg_provider_src_phone | String | Msg provider src phone no. |
| msg_provider_dest_phone | String | Msg provider dest phone no. |
| caddy_pipeline_repo | String | Github repo for caddy-hugo pipeline job. |
| caddy_pipeline_job | String | Caddy pipeline job name. |
| caddy_pipeline_file | String | Caddy pipeline script file. Jenkinsfile. |
| statuspage_api_key | String | Statuspage.io API key. |
| default_tags | Map | Default tags to add to resources. |

#### Sensitive inputs

Along with `terraform.tfvars` use another var file, `secrets.tfvars` for storing the senitive vars. This file is added in .gitignore.

Following inputs are taken from secrets.tfvars.

```HCL
aws_profile = "dev"
jenkins_admin_username = "admin"
jenkins_admin_password = "admin"
allowed_network = "0.0.0.0/0"
msg_provider_auth_id = "***************"
msg_provider_auth_token = "***************"
msg_provider_src_phone = "91**********"
msg_provider_dest_phone = "91**********"
statuspage_api_key = "**********************************"
sonarqube_db_password = "******************"
ssh_public_key = "/Complete/path/to/.ssh/id_rsa.pub"
```

#### How to use

1. Setup the VPC first. Terraform does not have a way to specify module dependency, and all other resource depend on the VPC.

```shell
terraform (plan|apply) -var-file=secrets.tfvars -target=module.vpc
```

2. Once VPC is done, create all other resources.

```shell
terraform (plan|apply) -var-file=secrets.tfvars
```

3. Give 5 mins for the services to come up and follow the links in terraform output.

#### Dependency Graph

![Dependency Graph](graph.png)

