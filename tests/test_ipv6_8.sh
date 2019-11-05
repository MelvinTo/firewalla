#!/bin/bash
​
ip -6 r | grep default &> /dev/null
​
IPV6_SUPPORT=$?
​
if [[ $IPV6_SUPPORT -ne 0 ]]; then
  exit 0
fi
​
IPV6_FLAG=$(redis-cli hget sys:features ipv6)
EID=$(redis-cli hget sys:ept eid)
​
if [[ $IPV6_FLAG == "1" ]]; then
  curl https://diag.firewalla.com/setup/ipv6/${EID}/alreadyOn &> /dev/null
  exit 0
fi
​
redis-cli hset sys:features ipv6 1
redis-cli publish "config:feature:dynamic:enable" "ipv6"
​
curl https://diag.firewalla.com/setup/ipv6/${EID}/enabled &> /dev/null
