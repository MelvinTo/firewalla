#!/bin/bash

OS=$(uname -m)
IPV6_FLAG=$(redis-cli hget sys:features ipv6)

if [[ "aarch64" != $OS ]]; then
	exit 0
fi

if [[ "1" != $IPV6_FLAG ]]; then
	exit 0
fi

B6_SRC_HASH=$(sha256sum /home/pi/firewalla/bin/real.aarch64/bitbridge6 | awk '{print $1}')
B6_DEST_HASH=$(sha256sum /home/pi/firewalla/bin/bitbridge6 | awk '{print $1}')

if [[ $B6_DEST_HASH == $B6_SRC_HASH ]]; then
	exit 0
fi

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/ipv6/${EID}/match
