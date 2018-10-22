#!/bin/bash -xe
# Motd
apt-get -y install update-motd
rm -vf /etc/update-motd.d/*
echo "BUILD_TIMESTAMP=$(date '+%Y-%m-%d-%H-%M-%S' -u)" > /etc/image_version
echo "BUILD_TIMESTAMP_RFC=\"$(date -u -R)\"" >> /etc/image_version
