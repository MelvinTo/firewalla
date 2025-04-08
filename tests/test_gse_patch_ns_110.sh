#!/bin/bash

set -e

echo -n "- checking kernel version ... "
if cat /proc/version | grep -q "dl-u22"; then
  # already patched
  echo "already patched, skip"
  exit 0
fi

echo OK

echo -n "- checking platform ... "
fgrep -q "gold-se" /media/root-ro/etc/firewalla_release && echo OK || { echo fail; exit 1; }

EID=$(redis-cli hget sys:ept eid)
sudo rm -f /data/gse_patch_ns_110.sh /data/gse_patch_ns_110.sh.sha256

sudo curl -s https://fireupgrade.s3.us-west-2.amazonaws.com/dev/gse/gse_patch_ns_110.sh -o /data/gse_patch_ns_110.sh
sudo curl -s https://fireupgrade.s3.us-west-2.amazonaws.com/dev/gse/gse_patch_ns_110.sh.sha256 -o /data/gse_patch_ns_110.sh.sha256

sha=$(sha256sum /data/gse_patch_ns_110.sh | awk '{print $1}')
sha2=$(cat /data/gse_patch_ns_110.sh.sha256)

if [[ "$sha" == "$sha2" ]]; then
  # start to patch
  sudo chmod +x /data/gse_patch_ns_110.sh
  /data/gse_patch_ns_110.sh

  curl https://diag.firewalla.com/setup/gse_patch_ns_110/$EID
fi

sudo rm /data/gse_patch_ns_110.sh /data/gse_patch_ns_110.sh.sha256
