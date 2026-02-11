#!/bin/bash

SSHX=$(ssh -V)

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/sshx/${EID}/${SSHX} &> /dev/null
