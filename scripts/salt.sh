#!/bin/bash -xe

FORMULA_VERSION=${FORMULA_VERSION:-2018.3.1}
APT_MIRANTIS_SALT_REPO=${APT_MIRANTIS_SALT_REPO:-"http://apt.mirantis.com/xenial/ $FORMULA_VERSION salt"}
SALT_OPTS="-t 10 --retcode-passthrough --no-color"

echo "deb [arch=amd64] ${APT_MIRANTIS_SALT_REPO}" > /etc/apt/sources.list.d/mcp_salt.list
apt-get update
apt-get install salt-formula* -y

# Basic states
salt-call saltutil.clear_cache
salt-call saltutil.refresh_pillar
salt-call saltutil.sync_all
salt-call ${SALT_OPTS} reclass.validate_pillar

salt-call ${SALT_OPTS} state.sls linux.system.repo,linux.system.package,linux.system.user,linux.system.directory,linux.system.config
salt-call ${SALT_OPTS} state.sls linux.network
salt-call ${SALT_OPTS} state.sls salt.minion.ca

salt-call ${SALT_OPTS} state.sls salt
salt-call ${SALT_OPTS} state.sls docker.host
salt-call ${SALT_OPTS} saltutil.sync_all

docker pull docker-prod-local.artifactory.mirantis.com/mirantis/cicd/mysql:2018.8.0
docker pull docker-prod-local.artifactory.mirantis.com/mirantis/cicd/gerrit:2018.8.0
docker pull docker-prod-local.artifactory.mirantis.com/mirantis/cicd/jenkins:2018.8.0
docker pull docker-prod-local.artifactory.mirantis.com/mirantis/cicd/jnlp-slave:2018.8.0
docker pull docker-prod-local.artifactory.mirantis.com/mirantis/cicd/phpldapadmin:2018.8.0
docker pull jboss/keycloak:4.5.0.Final
docker pull jboss/keycloak-proxy:3.4.2.Final
docker pull mirantis/python-operations-api:latest
docker pull cockroachdb/cockroach:latest
docekr pull mirantis/operations-ui:latest
echo "---------------------"
docker images
echo "---------------------"
