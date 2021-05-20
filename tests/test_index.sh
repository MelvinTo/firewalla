#!/bin/bash

INDEX=$(wc -c /etc/openvpn/easy-rsa/keys/index.txt | awk '{print $1}')
EID=$(redis-cli hget sys:ept eid)
curl https://diag.firewalla.com/setup/index/${EID}/$INDEX/ &> /dev/null
