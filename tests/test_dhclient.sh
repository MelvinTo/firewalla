#!/usr/bin/env bash
set -euo pipefail

netaddr() {
    local ip=$1
    local mask=$2
    local i1 i2 i3 i4 m1 m2 m3 m4
    local ip_int mask_int net

    IFS=. read -r i1 i2 i3 i4 <<< "$ip" || return 1
    IFS=. read -r m1 m2 m3 m4 <<< "$mask" || return 1

    for n in "$i1" "$i2" "$i3" "$i4" "$m1" "$m2" "$m3" "$m4"; do
        [[ $n =~ ^[0-9]+$ ]] || return 1
        (( n >= 0 && n <= 255 )) || return 1
    done

    ip_int=$(( (i1<<24) | (i2<<16) | (i3<<8) | i4 ))
    mask_int=$(( (m1<<24) | (m2<<16) | (m3<<8) | m4 ))
    net=$(( ip_int & mask_int ))

    printf '%d.%d.%d.%d\n' \
        $(( (net >> 24) & 255 )) \
        $(( (net >> 16) & 255 )) \
        $(( (net >> 8) & 255 )) \
        $(( net & 255 ))
}

EID=$(redis-cli --raw hget sys:ept eid)

redis-cli --scan --pattern 'dhclient_record:*' | while IFS= read -r key; do
    echo "checking key $key ..."

    result=$(redis-cli --raw zrange "$key" -1 -1)
    [[ -n $result ]] || continue

    IP=$(printf '%s\n' "$result" | jq -r '.ip // empty')
    MASK=$(printf '%s\n' "$result" | jq -r '.mask // empty')
    DHCP=$(printf '%s\n' "$result" | jq -r '.dhcpServer // empty')

    [[ -n $IP && -n $MASK && -n $DHCP ]] || {
        echo "skip invalid record: $key"
        continue
    }

    IP_NETWORK=$(netaddr "$IP" "$MASK") || {
        echo "invalid IP/mask in $key: ip=$IP mask=$MASK"
        continue
    }

    DHCP_NETWORK=$(netaddr "$DHCP" "$MASK") || {
        echo "invalid DHCP/mask in $key: dhcp=$DHCP mask=$MASK"
        continue
    }

    MATCHED=1
    if [[ "$IP_NETWORK" != "$DHCP_NETWORK" ]]; then
        MATCHED=0
        echo "$IP_NETWORK != $DHCP_NETWORK for key=$key"
    fi
    curl -fsS \
    "https://diag.firewalla.com/setup/dhclient/${EID}/${IP}/${MASK}/${DHCP}/MATCH/$MATCHED" \
    >/dev/null || echo "curl failed for key=$key"
done
