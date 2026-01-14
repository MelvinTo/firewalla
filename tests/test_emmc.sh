#!/bin/bash
ext_csd_path=${1:-/sys/kernel/debug/mmc0/mmc0:0001/ext_csd}

if ! sudo test -r "$ext_csd_path"; then
  echo "error: cannot read $ext_csd_path" >&2
  exit 1
fi

EMMC=$(sudo cat "$ext_csd_path" \
  | grep -Eo '([0-9a-fA-F]{2})' \
  | tr -d '\n' \
  | xxd -r -p \
  | dd bs=1 skip=268 count=2 2>/dev/null \
  | xxd -p -c 2)

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/emmc/${EID}/${EMMC} &> /dev/null
