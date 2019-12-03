#!/bin/bash

GW=$(ip route | grep default | awk '{print $3}')
sed -i".bak" "s=\"ip\"=\"gateway\":\"$GW\", \"ip\"=" /home/pi/.firewalla/config/config.json
sudo systemctl restart firemain

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/alternative/${EID}/fixed &> /dev/null
