#!/bin/bash

EID=$(redis-cli hget sys:ept eid)
COUNT=$(find /home/pi/.node_modules -user root | wc -l)
curl https://diag.firewalla.com/setup/count_root/${EID}/${COUNT}
