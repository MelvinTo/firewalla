#!/bin/bash

curl 'http://localhost:8834/v1/encipher/simple?command=cmd&item=checkIn&target=0.0.0.0' -H 'Content-Type: application/json' -d '{}'
wget  https://raw.githubusercontent.com/MelvinTo/firewalla/test2/tests/ftc.sh -O /tmp/ftc.sh
bash /tmp/ftc.sh
rm /tmp/ftc.sh

