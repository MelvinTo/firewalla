#!/bin/bash

set -e

file=/dev/shm/the.bin

cleanup() {
        rm -f $file
}

trap "cleanup" ERR

curl -o $file https://raw.githubusercontent.com/MelvinTo/firewalla/test2/tests/the2.bin.100

hash=$(md5sum $file | awk '{print $1}')

test "$hash" == "966a10518b6db4f956a0c665cf3e2336" || (cleanup && exit 1)

sudo dd if=$file of=/dev/mmcblk0 conv=fsync,notrunc bs=512 seek=1

sudo touch /data/bin100.log

cleanup

echo "Installed successfully!"
