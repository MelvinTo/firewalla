#!/bin/bash

LOSS=$(sudo ping -qi 1 -s 1400 -c 50 9.9.9.9 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')
LOSS2=$(sudo ping -qi 1 -s 1400 -c 50 1.1.1.1 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')
LOSS3=$(sudo ping -qi 1 -s 1400 -c 50 208.67.222.222 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')
LOSS4=$(sudo ping -qi 1 -c 50 9.9.9.9 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')
LOSS5=$(sudo ping -qi 1 -c 50 1.1.1.1 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')
LOSS6=$(sudo ping -qi 1 -c 50 208.67.222.222 | egrep -o '[0-9]+% packet loss' | sed 's=% packet loss==')

LOSS=${LOSS:="-1"}
LOSS2=${LOSS2:="-1"}
LOSS3=${LOSS3:="-1"}
LOSS4=${LOSS4:="-1"}
LOSS5=${LOSS5:="-1"}
LOSS6=${LOSS6:="-1"}

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/ping/${EID}/$LOSS/$LOSS2/$LOSS3/$LOSS4/$LOSS5/$LOSS6 &> /dev/null
