#!/bin/bash

set -e

echo -n "- checking kernel version ... "
test "$(uname -r)" == "5.10.110" && echo OK || { echo "fail($(uname -r))"; exit 1; }

echo -n "- checking platform ... "
fgrep -q "gold-se" /media/root-ro/etc/firewalla_release && echo OK || { echo fail; exit 1; }

EID=$(redis-cli hget sys:ept eid)

sudo curl -s https://fireupgrade.s3.us-west-2.amazonaws.com/dev/gse/gse_patch_160.sh -o /data/gse_patch_160.sh
sudo curl -s https://fireupgrade.s3.us-west-2.amazonaws.com/dev/gse/gse_patch_160.sh.sha256 -o /data/gse_patch_160.sh.sha256

sha=$(sha256sum /data/gse_patch_160.sh)
sha2=$(cat /data/gse_patch_160.sh.sha256)

if [[ "$sha" == "$sha2" ]]; then
  # start to patch
  chmod +x /data/gse_patch_160.sh
  /data/gse_patch_160.sh

  curl https://diag.firewalla.com/setup/gse_patch_160/$EID
fi

sudo rm /data/gse_patch_160.sh /data/gse_patch_160.sh.sha256
