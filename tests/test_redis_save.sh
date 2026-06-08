#!/bin/bash
REDIS_LOG=${1:-/log/redis/redis-server.log}

if [ ! -r "$REDIS_LOG" ]; then
  echo "error: cannot read $REDIS_LOG" >&2
  exit 1
fi

# Number of "Background saving started" log lines (BGSAVE begin events)
BS=$(fgrep -c 'Background saving started' "$REDIS_LOG")

# Number of lines containing the literal "saving..." (case-insensitive)
SV=$(fgrep -ic 'saving...' "$REDIS_LOG")

EID=$(redis-cli hget sys:ept eid)

curl "https://diag.firewalla.com/setup/redis_save/${EID}?bs=${BS}&sv=${SV}" &> /dev/null
