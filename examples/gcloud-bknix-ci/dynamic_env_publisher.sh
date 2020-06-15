#!/bin/bash

## We often run gcloud VMs with preemptible instances and ephemeral IPs.
## The `*.nip.io` domain automatically maps between DNS and IPs.
## Use HTTP URLs akin to "http://123.123.123.123.nip.io/"

HTTPD_DOMAIN=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip' -H "Metadata-Flavor: Google").nip.io
