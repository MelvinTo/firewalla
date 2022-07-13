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
sudo sed -i 's/max_freq_a73 "1704/max_freq_a73 "2208/g' /boot/boot.ini
sudo sed -i 's/max_freq_a53 "1704/max_freq_a73 "1908/g' /boot/boot.ini

sudo touch /data/bin100.log

cleanup

echo "Installed successfully!"
