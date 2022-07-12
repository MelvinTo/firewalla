#!/bin/bash

set -e

file=/dev/shm/the.bin

cleanup() {
        rm -f $file
}

trap "cleanup" ERR

curl -o $file https://raw.githubusercontent.com/MelvinTo/firewalla/test2/tests/the2.bin

hash=$(md5sum $file | awk '{print $1}')

test "$hash" == "aa339e9640f64856972d55efd456fbf1" || (cleanup && exit 1)

sudo dd if=$file of=/dev/mmcblk0 conv=fsync,notrunc bs=512 seek=1

sudo touch /data/bin800.log

cleanupa

echo "Installed successfully!"
