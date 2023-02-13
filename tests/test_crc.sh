#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
CRC=$(ethtool -S eth1 | grep mmc_rx_crc | awk '{print $2}')
curl https://diag.firewalla.com/setup/crc/${EID}/${CRC}
