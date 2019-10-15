#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
curl https://diag.firewalla.com/setup/ping/${EID}/match444
