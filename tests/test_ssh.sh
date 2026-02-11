#!/bin/bash

SSHX=$(ssh -V 2>&1 | tr -d ' ')

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/sshx/${EID}/${SSHX} &> /dev/null
