#!/bin/bash

sudo bash -c "cat > /etc/resolvconf/resolv.conf.d/head" <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

sudo systemctl restart resolvconf
