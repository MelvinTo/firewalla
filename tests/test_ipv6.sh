#!/bin/bash

OS=$(uname -m)
IPV6_FLAG=$(redis-cli hget sys:features ipv6)
EID=$(redis-cli hget sys:ept eid)

# Only focus on blue boxes
if [[ "aarch64" != $OS ]]; then
	exit 0
fi

# Only focus on boxes with ipv6 enabled
if [[ "1" != $IPV6_FLAG ]]; then
	exit 0
fi

# return error if ipv6 service is not online
if ! systemctl is-active bitbridge6; then
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match1234
else
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match5678
fi

exit 0

B6_SRC_HASH=$(sha256sum /home/pi/firewalla/bin/real.aarch64/bitbridge6 | awk '{print $1}')
B6_DEST_HASH=$(sha256sum /home/pi/firewalla/bin/bitbridge6 | awk '{print $1}')

if [[ $B6_DEST_HASH == $B6_SRC_HASH ]]; then
	exit 0
fi
