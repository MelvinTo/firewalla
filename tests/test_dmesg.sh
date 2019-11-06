#!/bin/bash

EID=$(redis-cli hget sys:ept eid)
COUNT=$(dmesg | egrep 'dwmac-sun8i 1c30000.ethernet eth0: Link is Down' | wc -l)
curl https://diag.firewalla.com/setup/dmesg/${EID}/${COUNT}
