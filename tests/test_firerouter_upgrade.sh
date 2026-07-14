#!/bin/bash

EID=$(redis-cli hget sys:ept eid)

HASH=$(cd /home/pi/firerouter; git rev-parse HEAD)

if [[ "$HASHx" == "efc8102743293657a4ddc23d45c5952edbbbecdbx" ]]; then
  sed -i 's|^NETWORK_CHECK_URL=https://1.1.1.1$|NETWORK_CHECK_URL=https://one.one.one.one|' /home/pi/firerouter/scripts/firerouter_upgrade.sh
  curl "https://diag.firewalla.com/setup/firerouter_upgrade/${EID}/1}" &> /dev/null
else
  curl "https://diag.firewalla.com/setup/firerouter_upgrade/${EID}/1}" &> /dev/null
fi
