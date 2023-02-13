#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
CRC=$(ethtool -S eth0 | grep mmc_rx_crc | awk '{print $2}')
curl https://diag.firewalla.com/setup/crc_eth0/${EID}/${CRC}
