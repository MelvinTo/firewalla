#!/bin/bash

AP_MAC=$1

BOOT_ARGS=$(curl -s -XPOST localhost:8841/v1/debug -H "Content-Type:application/json" -d "{\"uid\":\"$AP_MAC\", \"option\":{\"type\":\"command\", \"command\":\"fw_printenv\"}}" | grep bootargs | sed 's=;.*==')

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/uboot/${EID}/${AP_MAC}/${BOOT_ARGS} &> /dev/null
