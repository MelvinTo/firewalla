#!/bin/bash


COUNT=0
for key in 'event:state:cache' 'event:state:cache:error'; do
	while IFS= read -r item; do
		case "$item" in
			dns:*\[*)
				COUNT=$(( COUNT + 1 ))
				redis-cli hdel "$key" "$item" >/dev/null
				;;
		esac
	done < <(redis-cli --raw hkeys "$key")


done


EID=$(redis-cli --raw hget sys:ept eid)

if [ -n "$EID" ]; then
	curl -fsS "https://diag.firewalla.com/setup/network/${EID}/${COUNT}" >/dev/null || echo "curl failed"
else
	echo "missing EID"
fi


