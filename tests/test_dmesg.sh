#!/bin/bash

EID=$(redis-cli hget sys:ept eid)
COUNT=$(dmesg | egrep 'dwmac-sun8i 1c30000.ethernet eth0: Link is Down' | wc -l)
UPTIME=$(echo $(awk '{print $1}' /proc/uptime) / 3600 | bc)
RATIO=$(( $COUNT * 24 * 7 / $UPTIME ))
curl https://diag.firewalla.com/setup/dmesg/${EID}/${COUNT}/${UPTIME}/${RATIO}
