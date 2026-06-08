#!/bin/bash
ext_csd_path=${1:-/sys/kernel/debug/*mmc*/*mmc*/ext_csd}
ext_csd_path=$(sudo bash -c "ls -1 $ext_csd_path")

if ! sudo test -r "$ext_csd_path"; then
  echo "error: cannot read $ext_csd_path" >&2
  exit 1
fi

# JEDEC eMMC 5.x ext_csd offsets:
#   267 = PRE_EOL_INFO                  (1=normal, 2=warning, 3=urgent)
#   268 = DEVICE_LIFE_TIME_EST_TYP_A    (1..10 = 0-10..90-100% used, 11 = exceeded)
#   269 = DEVICE_LIFE_TIME_EST_TYP_B
HEX=$(sudo cat "$ext_csd_path" \
  | grep -Eo '([0-9a-fA-F]{2})' \
  | tr -d '\n' \
  | xxd -r -p \
  | dd bs=1 skip=267 count=3 2>/dev/null \
  | xxd -p -c 3)

EOL=${HEX:0:2}     # byte 267
EMMC=${HEX:2:4}    # bytes 268+269, unchanged 4-char contract

REDIS_MEM=$(redis-cli info memory | grep -i used_memory: | awk -F: '{print $2}')
EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/emmc/${EID}/${EMMC}${EOL}/${REDIS_MEM} &> /dev/null
