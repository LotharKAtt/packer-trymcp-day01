#!/bin/bash -xe

if [ -f '/done_ubuntu_salt_bootstrap' ]; then
  echo "INFO: ubuntu_salt_bootstrap already finished! Skipping.."
  exit 0
fi
#
CLUSTER_NAME=${CLUSTER_NAME:-lost_cluster_name_variable}
CLUSTER_MODEL=${CLUSTER_MODEL:-https://github.com/Mirantis/mcp-offline-model.git}
CLUSTER_MODEL_REF=${CLUSTER_MODEL_REF:-master}
FORMULA_VERSION=${FORMULA_VERSION:-testing}
SALTSTACK_GPG=${SALTSTACK_GPG:-"https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7/SALTSTACK-GPG-KEY.pub"}
SALTSTACK_REPO=${SALTSTACK_REPO:-"http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7 xenial main"}
APT_MIRANTIS_GPG=${APT_MIRANTIS_GPG:-"http://apt.mirantis.com/public.gpg"}
APT_MIRANTIS_SALT_REPO=${APT_MIRANTIS_SALT_REPO:-"http://apt.mirantis.com/xenial/ $FORMULA_VERSION salt"}
GIT_SALT_FORMULAS_SCRIPTS=${GIT_SALT_FORMULAS_SCRIPTS:-"https://github.com/salt-formulas/salt-formulas-scripts"}
GIT_SALT_FORMULAS_SCRIPTS_REF=${GIT_SALT_FORMULAS_SCRIPTS_REF:-master}

function process_repos(){
# TODO: those  should be unhardcoded and re-writed, using CC model
wget -O - ${SALTSTACK_GPG} | sudo apt-key add -
wget -O - ${APT_MIRANTIS_GPG} | apt-key add -
wget -O - http://mirror.mirantis.com/${FORMULA_VERSION}/extra/xenial/archive-extra.key | apt-key add -

echo "deb [arch=amd64] ${SALTSTACK_REPO}"  > /etc/apt/sources.list.d/mcp_saltstack.list
echo "deb [arch=amd64] http://mirror.mirantis.com/${FORMULA_VERSION}/extra/xenial xenial main"  > /etc/apt/sources.list.d/mcp_extra.list

# This Pin-Priority fix should be always aligned with
# https://github.com/Mirantis/reclass-system-salt-model/blob/master/linux/system/repo/mcp/apt_mirantis/saltstack.yml
# saltstack
cat <<EOF >> /etc/apt/preferences.d/mcp_saltstack
Package: libsodium18
Pin: release o=SaltStack
Pin-Priority: 50

Package: *
Pin: release o=SaltStack
Pin-Priority: 1100
EOF
# reclass
cat <<EOF >> /etc/apt/preferences.d/mcp_extra
Package: *
Pin: release o=Mirantis
Pin-Priority: 1100
EOF
}

process_repos
apt-get update
apt-get install git-core reclass -y

rm -v /etc/apt/sources.list.d/mcp_extra.list /etc/apt/preferences.d/mcp_extra

for g_host in ${CLUSTER_MODEL} ${GIT_SALT_FORMULAS_SCRIPTS} ; do
  _tmp_host=$(echo ${g_host} | awk -F/ '{print $3}')
  ssh-keyscan -T 1 -H ${_tmp_host} >> ~/.ssh/known_hosts || true
done

if [[ ! -d /srv/salt/reclass ]]; then
  git clone --recursive ${CLUSTER_MODEL} /srv/salt/reclass
  pushd /srv/salt/reclass/
    git checkout ${CLUSTER_MODEL_REF}
  popd
fi

if [[ ! -d /srv/salt/scripts ]]; then
  git clone --recursive ${GIT_SALT_FORMULAS_SCRIPTS} /srv/salt/scripts
  pushd /srv/salt/scripts/
    git checkout ${GIT_SALT_FORMULAS_SCRIPTS_REF}
  popd
fi

# bootstrap.sh opts
export FORMULAS_SOURCE=pkg
export HOSTNAME=${BS_HOSTNAME:-lost_bs_hostname_variable}
export DOMAIN="${CLUSTER_NAME}.local"
export EXTRA_FORMULAS=${EXTRA_FORMULAS:-"ntp aptly nginx iptables docker git maas logrotate jenkins sphinx gerrit openldap keycloak"}
export APT_REPOSITORY=" deb [arch=amd64] ${APT_MIRANTIS_SALT_REPO} "
export APT_REPOSITORY_GPG=${APT_MIRANTIS_GPG}
export SALT_STOPSTART_WAIT=${SALT_STOPSTART_WAIT:-10}
echo "INFO: build in offline build!"
export BOOTSTRAP_SALTSTACK_COM="file:///opt/bootstrap.saltstack.com.sh"
# extra opts will push bootstrap script NOT install upstream repos.
export BOOTSTRAP_SALTSTACK_OPTS=${BOOTSTRAP_SALTSTACK_OPTS:- -dXr $BOOTSTRAP_SALTSTACK_VERSION }
#

if [[ ! -f /srv/salt/scripts/bootstrap.sh ]]; then
  echo "ERROR: File /srv/salt/scripts/bootstrap.sh not found"
  exit 1
fi
bash -x /srv/salt/scripts/bootstrap.sh || true
touch /done_ubuntu_salt_bootstrap
