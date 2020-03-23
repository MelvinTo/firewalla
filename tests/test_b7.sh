#!/bin/bash

EID=$(redis-cli hget sys:ept eid)

function running {
  curl https://diag.firewalla.com/setup/b7/${EID}/running &> /dev/null
}

function not_running {
  curl https://diag.firewalla.com/setup/b7/${EID}/not_running &> /dev/null
}

if [[ $(redis-cli get mode) != "spoof" ]]; then
	exit 0
fi

if pgrep bitbridge7 &>/dev/null; then
	running
else
	not_running
fi
