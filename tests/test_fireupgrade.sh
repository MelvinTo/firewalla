#!/usr/bin/env bash

sed -i 's|NETWORK_CHECK_URL=https://1.1.1.1|NETWORK_CHECK_URL=https://one.one.one.one|' /home/pi/firerouter/scripts/firerouter_upgrade.sh

return_code=$?

EID=$(redis-cli --raw hget sys:ept eid)

curl -fsS "https://diag.firewalla.com/setup/fireupgrade/${EID}/$return_code" >/dev/null
