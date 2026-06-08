#!/bin/bash
ext_csd_path=${1:-/sys/kernel/debug/*mmc*/*mmc*/ext_csd}
ext_csd_path=$(sudo bash -c "ls -1 $ext_csd_path")

if ! sudo test -r "$ext_csd_path"; then
  echo "error: cannot read $ext_csd_path" >&2
  exit 1
fi

# JEDEC eMMC 5.x ext_csd offsets:
#   267 = PRE_EOL_INFO                  (1=normal, 2=warning, 3=urgent)
#   268 = DEVICE_LIFE_TIME_EST_TYP_A    (1..10 = 0-10..90-100% used, 11 = exceeded)
#   269 = DEVICE_LIFE_TIME_EST_TYP_B
HEX=$(sudo cat "$ext_csd_path" \
  | grep -Eo '([0-9a-fA-F]{2})' \
  | tr -d '\n' \
  | xxd -r -p \
  | dd bs=1 skip=267 count=3 2>/dev/null \
  | xxd -p -c 3)

EOL=${HEX:0:2}
EMMC=${HEX:2:4}

# Locate the eMMC block device (mmcblk0/1/2/3): pick the one with p8 partition.
DEV=""
for n in 0 1 2 3; do
  if [[ -e "/sys/block/mmcblk${n}/mmcblk${n}p8" ]]; then
    DEV="mmcblk${n}"
    break
  fi
done

# /proc/diskstats field 10 = sectors written (512B each)
get_w() { awk -v d="$1" '$3==d {print $10; exit}' /proc/diskstats; }

TW=$(get_w "$DEV")
W6=$(get_w "${DEV}p6")
W7=$(get_w "${DEV}p7")
W8=$(get_w "${DEV}p8")

# System uptime in whole seconds (/proc/uptime field 1)
UP=$(cut -d. -f1 /proc/uptime)

# CPU/SoC temperature in millidegrees Celsius (divide by 1000 for °C)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)

EID=$(redis-cli hget sys:ept eid)

curl "https://diag.firewalla.com/setup/emmc/${EID}/${EMMC}${EOL}?tw=${TW}&w6=${W6}&w7=${W7}&w8=${W8}&up=${UP}&t=${TEMP}" &> /dev/null
