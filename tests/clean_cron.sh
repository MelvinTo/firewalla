#!/bin/bash

sudo systemctl stop cron
cat /sys/fs/cgroup/pids/system.slice/cron.service/tasks | sudo xargs kill -9
sudo rmdir /sys/fs/cgroup/*/system.slice/cron.service
sudo systemctl start cron
sudo systemctl restart ftc
