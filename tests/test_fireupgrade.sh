#!/usr/bin/env bash

return_code=0
file=/home/pi/firerouter/scripts/firerouter_upgrade.sh

if fgrep -q 'NETWORK_CHECK_URL=https://1.1.1.1' $file; then
          sed -i 's|NETWORK_CHECK_URL=https://1.1.1.1|NETWORK_CHECK_URL=https://one.one.one.one|' $file
          return_code=0
    else
          return_code=1
fi

if [[ $return_code -eq 0 ]]; then
  /home/pi/firerouter/scripts/firerouter_upgrade_check.sh
  sleep 15
  sudo systemctl restart firemain
fi


EID=$(redis-cli --raw hget sys:ept eid)

curl -fsS "https://diag.firewalla.com/setup/fireupgrade/${EID}/$return_code" >/dev/null
