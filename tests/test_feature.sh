#!/bin/bash

FEATURE_NAME=$1
EXPECT_TARGET=$2

EID=$(redis-cli hget sys:ept eid)
ACTUAL_TARGET=$(redis-cli hget sys:features $FEATURE_NAME)

if [[ $ACTUAL_TARGET == $EXPECT_TARGET ]]; then
  curl https://diag.firewalla.com/setup/feature/${EID}/${FEATURE_NAME}/not_change &> /dev/null
  exit 0
fi


redis-cli hset sys:features $FEATURE_NAME $EXPECT_TARGET
if [[ $EXPECT_TARGET -eq 1 ]]; then
  redis-cli publish "config:feature:dynamic:enable" "$FEATURE_NAME"
elsif [[ $EXPECT_TARGET -eq 0 ]]; then
  redis-cli publish "config:feature:dynamic:disable" "$FEATURE_NAME"
fi
curl https://diag.firewalla.com/setup/feature/${EID}/${FEATURE_NAME}/${EXPECT_TARGET} &> /dev/null
