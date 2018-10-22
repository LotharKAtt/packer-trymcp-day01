#!/bin/bash -xe

# stop and disable services, for healthy zerodisk
# They should be enabled after cfg01 init
stop_services="postgresql.service salt-api salt-master salt-minion maas-rackd.service maas-regiond.service bind9"
for s in ${stop_services} ; do
  systemctl stop ${s} || true
  systemctl disable ${s} || true
done

echo 3 > /proc/sys/vm/drop_caches
sync
