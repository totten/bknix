#!/bin/bash

RAMDISKSIZE=250M
HTTPD_DOMAIN=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip' -H "Metadata-Flavor: Google").nip.io
PROFILES="min"
