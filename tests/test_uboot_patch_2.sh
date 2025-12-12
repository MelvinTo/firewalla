#!/bin/bash

AP_MAC=$1

function patch_ap() {
  local mac=$1
  local version=$2

  local payload=$(jq -n --arg mac "$mac" --arg version "$version" '{"uid": $mac, "version": $version}')
  curl -XPOST localhost:8841/v1/control/patch_version -d "$payload" -H "Content-Type:application/json"
}

patch_ap $AP_MAC 1.8.53

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/uboot_patch/${EID}/${AP_MAC}/1 &> /dev/null
