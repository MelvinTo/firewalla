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

sudo systemctl restart bitbridge6
