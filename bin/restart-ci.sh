#!/bin/bash

set -e

echo "Stopping all services"
systemctl stop bknix-{dfl,min,max}{,-mysqld} mnt-mysql-jenkins.mount

echo "Waiting"
# Don't know if this is actually needed, but it's improved reliability in the past.
sleep 5

echo "Starting all services"
systemctl start mnt-mysql-jenkins.mount bknix-{dfl,min,max}{,-mysqld}
