#!/bin/bash

## This is a full reset - shutting down all systems, recreating all config files, and restarting all systems

set -e

echo "Stopping services"
systemctl stop bknix-{dfl,min,max}{,-mysqld}

echo "Waiting"
# Don't know if this is actually needed, but it's improved reliability in the past.
sleep 5

echo "Stopping ramdisk"
systemctl stop mnt-mysql-jenkins.mount

echo "Reinstalling profiles"
FORCE_INIT=-f ./bin/install-gcloud.sh

echo "Starting ramdisk"
systemctl start mnt-mysql-jenkins.mount

echo "Starting services"
systemctl start bknix-{dfl,min,max}{,-mysqld}

echo "Updating buildkit"
./bin/update-ci-buildkit.sh

echo "Warming up caches"
./bin/cache-warmup.sh
