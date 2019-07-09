#!/bin/bash

HASHED_MAC=$1
ACTION="false"

if [[ "x$2" != "x" ]]; then
  ACTION="true"
fi

moff() {
  curl -s -o /dev/null -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d "{ \"monitor\": $ACTION }" 'http://localhost:8834/v1/encipher/simple?command=set&item=policy&target='$1
}

for h in `redis-cli keys "host:mac:*" | sed "s=host:mac:=="`; do
  HASHED=$(echo -n $h | sha256sum | awk '{print $1}' | xxd -r -p | base64)
  if [[ $HASHED == $HASHED_MAC ]]; then
    moff $h
  fi
done
