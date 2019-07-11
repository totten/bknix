#!/bin/bash

## This ramdisk is smaller than usual because we use pre-emptible instances that don't retain data as long.
RAMDISKSIZE=4G
HTTPD_DOMAIN=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip' -H "Metadata-Flavor: Google").nip.io
PROFILES="dfl min max edge"
