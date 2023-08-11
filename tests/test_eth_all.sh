#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
CRC0=$(ethtool -S eth0 | grep rx_crc_errors: | awk '{print $2}')
CRC1=$(ethtool -S eth1 | grep rx_crc_errors: | awk '{print $2}')
LINK1=$(ethtool eth1 2>/dev/null | tail -n 1| awk -F: '{print $2}' | tr -d " ")
S1=$(ethtool eth1 2>/dev/null | grep -i speed | awk -F: '{print $2}' | tr -d " ")
CRC2=$(ethtool -S eth2 | grep rx_crc_errors: | awk '{print $2}')
LINK2=$(ethtool eth2 2>/dev/null | tail -n 1| awk -F: '{print $2}' | tr -d " ")
S2=$(ethtool eth2 2>/dev/null | grep -i speed | awk -F: '{print $2}' | tr -d " ")
CRC3=$(ethtool -S eth3 | grep rx_crc_errors: | awk '{print $2}')
curl https://diag.firewalla.com/setup/crc_eth_all/${EID}/${CRC0}/${CRC1}/${CRC2}/${CRC3}/${LINK1}/${LINK2}/${S1}/${S2}/X
