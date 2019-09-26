#!/bin/bash

COUNT=$(redis-cli keys 'flowgraph:*' | xargs -n 1 -I ZZZ redis-cli ttl ZZZ | fgrep -- '-1' | wc -l)
EID=$(redis-cli hget sys:ept eid)
curl https://diag.firewalla.com/setup/flow/${EID}/${COUNT}
