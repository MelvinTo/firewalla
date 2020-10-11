#!/bin/bash

EID=$(redis-cli hget sys:ept eid)
FILE=$(find /home/pi/.node_modules -user root | head -n 1)
curl https://diag.firewalla.com/setup/count_root_file/${EID}/${FILE}
