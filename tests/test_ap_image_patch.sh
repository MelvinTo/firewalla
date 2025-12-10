#!/bin/bash

AP_MAC=$1

function patch_ap_image() {
  local mac=$1
  local version=$2
  local channel=$3

  local payload=$(jq -n --arg mac "$mac" --arg channel "$channel" --arg version "$version" '{"uid": $mac, "version": $version, "channel": $channel}')
  curl -XPOST localhost:8841/v1/control/image_upgrade -d "$payload" -H "Content-Type:application/json"
}

patch_ap_image "$AP_MAC" 0.1.114 alpha

EID=$(redis-cli hget sys:ept eid)

curl https://diag.firewalla.com/setup/patch_ap_image/${EID}/${AP_MAC}/1 &> /dev/null
