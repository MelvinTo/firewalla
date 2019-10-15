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
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match12340
  sudo systemctl start bitbridge6
else
  curl https://diag.firewalla.com/setup/ipv6/${EID}/match56780
fi
