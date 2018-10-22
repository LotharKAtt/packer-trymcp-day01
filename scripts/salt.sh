#!/bin/bash -xe

FORMULA_VERSION=${FORMULA_VERSION:-2018.3.1}
APT_MIRANTIS_SALT_REPO=${APT_MIRANTIS_SALT_REPO:-"http://apt.mirantis.com/xenial/ $FORMULA_VERSION salt"}
#SALT_OPTS="-t 10 --retcode-passthrough --no-color"
# zbuildi se vzdy
SALT_OPTS="-t 10"
#salt-call ${SALT_OPTS} reclass.validate_pillar

echo "deb [arch=amd64] ${APT_MIRANTIS_SALT_REPO}" > /etc/apt/sources.list.d/mcp_salt.list
apt-get update
apt-get install salt-formula* -y

# Basic states
salt-call saltutil.refresh_pillar
salt-call ${SALT_OPTS} state.sls linux.system.repo,linux.system.package,linux.system.user,linux.system.directory,linux.system.config
salt-call ${SALT_OPTS} state.sls linux.network
salt-call ${SALT_OPTS} state.sls openssh
salt-call ${SALT_OPTS} state.sls salt.minion.ca
sleep 20
echo "Minion CA"
salt-call ${SALT_OPTS} state.sls salt.minion.cert
echo "Minion Cert"
sleep 20
salt-call ${SALT_OPTS} state.sls salt
echo "Minion pure salt"
sleep 20
#SWARM
#peklo
sleep 20
salt-call ${SALT_OPTS} state.sls docker.host
salt-call ${SALT_OPTS} state.sls docker.swarm
salt-call ${SALT_OPTS} mine.flush
salt-call ${SALT_OPTS} mine.update
salt-call ${SALT_OPTS} saltutil.sync_all

sleep 20
salt-call ${SALT_OPTS} state.sls docker.swarm
echo "Swarm 2"
sleep 20
CICD
salt-call ${SALT_OPTS} state.sls nginx
sleep 25
salt-call ${SALT_OPTS} state.sls docker.client
echo "docker client1"
sleep 60
salt-call ${SALT_OPTS} state.sls openldap
sleep 5
salt-call ${SALT_OPTS} state.sls gerrit
sleep 5
salt-call ${SALT_OPTS} state.sls gerrit
salt-call ${SALT_OPTS} state.sls jenkins
