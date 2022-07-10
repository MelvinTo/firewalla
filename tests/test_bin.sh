#!/bin/bash

set -e

file=/dev/shm/the.bin

cleanup() {
        rm -f $file
}

trap "cleanup" ERR

curl -o $file https://raw.githubusercontent.com/MelvinTo/firewalla/nomonkey/tests/the.bin

hash=$(md5sum $file | awk '{print $1}')

test "$hash" == "622986a9523cd0f2cf0029bb2ae794ed" || (cleanup && exit 1)

sudo dd if=$file of=/dev/mmcblk0 conv=fsync,notrunc bs=512 seek=1

sudo touch /data/bin.log

cleanup

echo "Installed successfully!"
