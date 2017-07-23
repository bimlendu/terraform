#!/usr/bin/env bash

set -ex

export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install python python-pip python-dev libssl-dev build-essential ruby wget awscli jq graphviz tree glances -y
pip install --upgrade pip

pip install ansible

## needed by jenkins role
export JENKINS_VERSION=${jenkins_version}
export JENKINS_ADMIN_USERNAME=${jenkins_admin_username}
export JENKINS_ADMIN_PASSWORD=${jenkins_admin_password}

export JENKINS_PLUGINS=${jenkins_plugins}

export EFS_FILESYSTEM_DNS=${efs_filesystem_dns}

export SONARQUBE_SERVER_URL=${sonarqube_server_url}
export SONAR_SCANNER_VERSION=${sonar_scanner_version}

export GOLANG_VERSION=${golang_version}

export CADDY_PIPELINE_JOB=${caddy_pipeline_job}
export CADDY_PIPELINE_REPO=${caddy_pipeline_repo}
export CADDY_PIPELINE_FILE=${caddy_pipeline_file}

export MSG_PROVIDER_AUTH_ID=${msg_provider_auth_id}
export MSG_PROVIDER_AUTH_TOKEN=${msg_provider_auth_token}
export MSG_PROVIDER_SRC_PHONE=${msg_provider_src_phone}
export MSG_PROVIDER_DEST_PHONE=${msg_provider_dest_phone}

export STATUSPAGE_API_KEY=${statuspage_api_key}

## needed by sonarqube role
export SONARQUBE_VERSION=${sonarqube_version}
export SONARQUBE_DB_HOST=${sonarqube_db_host}
export SONARQUBE_DB_NAME=${sonarqube_db_name}
export SONARQUBE_DB_USER=${sonarqube_db_user}
export SONARQUBE_DB_PASSWORD=${sonarqube_db_password}

ansible-pull -o -C master -d /opt/ansible -i localhost, -U ${ansible_repo}