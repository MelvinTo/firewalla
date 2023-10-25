#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
HANG0=$(sudo bash -c "cd /var/log; cat kern.log kern.log.1; zcat kern.log*.gz" 2>/dev/null | grep -a 'eth0: Detected Tx Unit Hang' | wc -l)
HANG1=$(sudo bash -c "cd /var/log; cat kern.log kern.log.1; zcat kern.log*.gz" 2>/dev/null | grep -a 'eth1: Detected Tx Unit Hang' | wc -l)
HANG2=$(sudo bash -c "cd /var/log; cat kern.log kern.log.1; zcat kern.log*.gz" 2>/dev/null | grep -a 'eth2: Detected Tx Unit Hang' | wc -l)
HANG3=$(sudo bash -c "cd /var/log; cat kern.log kern.log.1; zcat kern.log*.gz" 2>/dev/null | grep -a 'eth3: Detected Tx Unit Hang' | wc -l)

curl https://diag.firewalla.com/setup/tx_hang/${EID}/${HANG0}/${HANG1}/${HANG2}/${HANG3}
