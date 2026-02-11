#!/bin/bash

SSHX=$(ssh -V)

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/uboot/${EID}/${SSHX} &> /dev/null
