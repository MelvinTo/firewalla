#!/bin/bash

test -e ~/.firewalla/config/config.json || exit 0

grep alternativeInterface ~/.firewalla/config/config.json &>/dev/null || exit 0

grep -A 2 alternativeInterface ~/.firewalla/config/config.json | grep '"ip"' || exit 0

grep -A 2 alternativeInterface ~/.firewalla/config/config.json | grep '"gateway"' && exit 0

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/alternative/${EID}/enabled &> /dev/null
