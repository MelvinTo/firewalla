#!/bin/bash
EID=$(redis-cli hget sys:ept eid)
CRC0=$(ethtool -S eth0 | grep rx_crc_errors: | awk '{print $2}')
CRC1=$(ethtool -S eth1 | grep rx_crc_errors: | awk '{print $2}')
CRC2=$(ethtool -S eth2 | grep rx_crc_errors: | awk '{print $2}')
CRC3=$(ethtool -S eth3 | grep rx_crc_errors: | awk '{print $2}')
curl https://diag.firewalla.com/setup/crc_eth_all/${EID}/${CRC0}/${CRC1}/${CRC2}/${CRC3}
