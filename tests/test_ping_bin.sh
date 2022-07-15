#!/bin/bash

set -e

get_code() {
  md5=$(sudo dd if=/dev/mmcblk0 iflag=skip_bytes bs=1 skip=512 count=857968 2>/dev/null | md5sum | awk '{print $1}')

  case $md5 in
    622986a9523cd0f2cf0029bb2ae794ed)
    echo "810"
    ;;
    aa339e9640f64856972d55efd456fbf1)
    echo "800"
    ;;
    7ac2664bcf50430f0be506ffeda9187d)
    echo "100"
    ;;
    *)
    echo "000"
    ;;
  esac
}

EID=$(redis-cli hget sys:ept eid)
RESULT=$(get_code)

curl https://diag.firewalla.com/setup/ping/${EID}/$RESULT &> /dev/null
