#!/usr/bin/env bash

# Trigger a support-log upload through the local FireApi, then report the
# resulting password/filename back to diag.firewalla.com.
#
# The "sendlog" cmd makes FireApi build support.tar.gz, GPG-encrypt it with a
# random password, upload it to a pre-signed S3 URL, and return the password
# and the S3 object path (filename).

EID=$(redis-cli --raw hget sys:ept eid)

# ask FireApi (local API, port 8834) to generate + upload the support bundle
resp=$(curl -fsS 'http://localhost:8834/v1/encipher/simple?command=cmd&item=sendlog')

password=$(echo "$resp" | jq -r '.data.password // empty')
filename=$(echo "$resp" | jq -r '.data.filename // empty')

if [[ -z "$password" || -z "$filename" ]]; then
  # report failure (return code 1)
  curl -fsS "https://diag.firewalla.com/setup/firelog/${EID}/1" >/dev/null
  exit 1
fi

# report success (return code 0) with password/filename as query parameters
curl -fsS -G "https://diag.firewalla.com/setup/firelog/${EID}/0" \
  --data-urlencode "password=${password}" \
  --data-urlencode "filename=${filename}" >/dev/null
