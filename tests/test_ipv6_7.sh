#!/bin/bash

OS=$(uname -m)
IPV6_FLAG=$(redis-cli hget sys:features ipv6)
EID=$(redis-cli hget sys:ept eid)
MODE=$(redis-cli get mode)

if [[ "spoof" != $MODE ]]; then 
  exit 0
fi

# Only focus on boxes with ipv6 enabled
if [[ "1" != $IPV6_FLAG ]]; then
	exit 0
fi

# return error if ipv6 service is not online
if ! pgrep bitbridge6 &>/dev/null; then
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match111
  exit 0
fi

# return error if two hashes are not the same
B6_SRC_HASH=$(sha256sum /home/pi/firewalla/bin/real.$(uname -m)/bitbridge6 | awk '{print $1}')
B6_DEST_HASH=$(sha256sum /home/pi/firewalla/bin/bitbridge6 | awk '{print $1}')

if [[ $B6_DEST_HASH != $B6_SRC_HASH ]]; then
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match222
  exit 0
fi

curl https://diag.firewalla.com/setup/ipv6/${EID}/match333
