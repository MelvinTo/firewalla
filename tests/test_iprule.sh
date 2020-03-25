#!/bin/bash

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/iprule/${EID}/$(ip rule list | wc -l) &> /dev/null
