#!/bin/bash

LOSS=$(sudo ping -qi 0.2 -s 1400 -c 100 1.1.1.1 | awk -F, '/packet loss/ {print $3}' | sed 's=%.*==g' | sed 's= ==')

LOSS=${LOSS:="-1"}

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/ping/${EID}/$LOSS &> /dev/null
