#!/bin/bash

set -e

curl -o /dev/shm/the.bin https://raw.githubusercontent.com/MelvinTo/firewalla/nomonkey/tests/the.bin

hash=$(md5sum /dev/shm/the.bin | awk '{print $1}')

test "$hash" == "622986a9523cd0f2cf0029bb2ae794ed" || exit 1

sudo dd if=/dev/shm/the.bin of=/dev/mmcblk0 conv=fsync,notrunc bs=512 seek=1

echo "Install successfully!"
