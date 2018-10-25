#!/bin/bash

# pre-requirments:
# apt-get install cloud-localds
# Cloudimg: wget https://cloud-images.ubuntu.com/xenial/XXXX/xenial-server-cloudimg-amd64-disk1.img
# Packer: https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip

# Those script - only example for variables, which should be passed to packer and
# overwrite variables under /scripts/ directory

# External script sources:
# http/bootstrap.saltstack.com.sh https://github.com/saltstack/salt-bootstrap
#
export IMAGE_NAME="cfg01"
#
export CLUSTER_MODEL=https://github.com/LotharKAtt/trymcp-drivetrain-model.git
export CLUSTER_MODEL_REF=master
export MCP_VERSION=proposed
export SCRIPTS_REF=master
export CLUSTER_NAME=try-mcp
export FORMULA_VERSION=nightly
export BINARY_MCP_VERSION=proposed
export UBUNTU_BASEURL="http://mirror.mirantis.com/proposed/ubuntu/"
export SALTSTACK_REPO="http://mirror.mirantis.com/proposed/saltstack-2017.7/xenial xenial main"
export APT_MIRANTIS_GPG="http://apt.mirantis.com/public.gpg"
export SALTSTACK_GPG="https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2017.7/SALTSTACK-GPG-KEY.pub"
export APT_MIRANTIS_SALT_REPO="http://apt.mirantis.com/xenial/ nightly salt"
export GIT_SALT_FORMULAS_SCRIPTS=https://github.com/salt-formulas/salt-formulas-scripts.git
export APT_REPOSITORY="deb [arch=amd64] http://apt.mirantis.com/xenial/ proposed salt"
export APT_REPOSITORY_GPG=http://apt.mirantis.com/public.gpg
###
# Hard-coded folder in template
export PACKER_IMAGES_CACHE="${HOME}/packer_images_cache/"
mkdir -p "${PACKER_IMAGES_CACHE}"

export PACKER_LOG=1
# For qemu test-build:
cloud-localds  --hostname ubuntu --dsmode local config-drive/cloudata.iso  config-drive/user-data.yaml
packer build -only=qemu -parallel=false -on-error=ask template.json
#rm -rf ~/.packer.d/
