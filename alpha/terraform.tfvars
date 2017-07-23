name = "alpha"
region = "us-east-1"

ansible_repo = "https://github.com/bimlendu/ansible-roles.git"

jenkins_instance_type = "m4.large"
jenkins_version = "2.60.2"
jenkins_plugins = "workflow-aggregator golang credentials-binding git timestamper ws-cleanup junit blueocean sonar pipeline-aws http_request"

sonarqube_version = "6.4"
sonarqube_db_name = "sonarqube"
sonarqube_db_user = "sonarqube"
sonarqube_server_url = "http://localhost:9000"
sonar_scanner_version = "3.0.3.778"

golang_version = "1.8.3"

caddy_pipeline_job = "caddy-hugo"
caddy_pipeline_repo = "https://github.com/bimlendu/caddy-hugo.git"
caddy_pipeline_file = "Jenkinsfile"

default_tags = {
  ManagedBy = "Terraform"
  Creator   = "Bimlendu"
}