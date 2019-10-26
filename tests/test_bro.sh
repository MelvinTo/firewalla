#!/bin/bash

if [[ ! -e /blog/current/conn.log ]]; then
  exit 0
fi

LAST_CONN_TS=$(tail -n 1 /blog/current/conn.log | json_pp | grep -w ts | awk '{print $3}' | sed 's=\..*$==')

NOW=$(date +%s)
DIFF=$(( $NOW - $LAST_CONN_TS ))

EID=$(redis-cli hget sys:ept eid)

if [[ $DIFF -gt 1800 ]]; then
  curl https://diag.firewalla.com/setup/bro/${EID}/$DIFF
fi
