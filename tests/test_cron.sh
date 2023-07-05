#!/bin/bash

#set -x

UPTIME=$(cat /proc/uptime  | awk '{print $1}')
EID=$(redis-cli hget sys:ept eid)
CRON=$(cat /sys/fs/cgroup/pids/system.slice/cron.service/pids.current || echo -1)
FTC=$(cat /sys/fs/cgroup/pids/system.slice/ftc.service/pids.current || echo -1)
TASK=$(sudo cat /proc/slabinfo | grep task_struct | awk '{print $2}')
curl https://diag.firewalla.com/setup/cron/${EID}/$UPTIME/${CRON}_${FTC}_${TASK}
