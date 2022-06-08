#!/bin/bash

LOSS=$(sudo ping -qi 0.02 -s 1400 -c 100 $(ip r show default | sort -nk7 | awk '{print $3; exit}') | awk -F, '/packet loss/ {print $3}')

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/ping/${EID}/$LOSS &> /dev/null
