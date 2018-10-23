#!/bin/bash

# This installs each of the bknix profiles in a way that's useful for the CI servers.
# Specifically, for each profile:
#   - Install the binaries in /nix/var/nix/profiles/bknix-$PROFILE
#   - Initialize a data folder in /home/$OWNER/bknix-$PROFILE
#   - Add a background service for `bknix run` (systemd)
#
# Pre-requisites:
#   Use a Debian-like main OS
#   Install the "nix" package manager.
#   Only tested with multiuser mode.
#   Login as proper root (e.g. `sudo -i bash`)
#
# Example: Install (or upgrade) all the profiles
#   ./bin/install-gcloud.sh
#
# Example: Install (or upgrade) all the profiles, overwriting any local config files
#   FORCE_INIT=-f ./bin/install-gcloud.sh
#
# Example:
#   NO_AUTOSTART=1 ./bin/install-gcloud.sh
#
# After installation, an automated script can use a statement like:
#    eval $(use-bknix min)
#    eval $(use-bknix max)
#    eval $(use-bknix dfl)

###########################################################
## Primary install routines

## Setup all services for user "jenkins"
function install_all_jenkins() {
  OWNER=jenkins
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=4G
  HTTPD_DOMAIN=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip' -H "Metadata-Flavor: Google").nip.io
  ## TODO: move customizations for RAMDISKSIZE and HTTPD_DOMAIN? then we can start using the normal copy of install_all_jenkins()?

  [ -f /etc/bknix-ci/install_all_jenkins.sh ] && source /etc/bknix-ci/install_all_jenkins.sh

  install_user
  install_ramdisk

  PROFILE=dfl HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8001 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 MYSQLD_PORT=3307 install_profile
  PROFILE=min HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8002 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 MYSQLD_PORT=3308 install_profile
  PROFILE=max HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8003 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 MYSQLD_PORT=3309 install_profile

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE
}

## Setup all services for user "publisher"
function install_all_publisher() {
  OWNER=publisher
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=500M
  HTTPD_DOMAIN=$(curl 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip' -H "Metadata-Flavor: Google").nip.io
  ## TODO: move customizations for RAMDISKSIZE and HTTPD_DOMAIN? then we can start using the normal copy of install_all_jenkins()?

  [ -f /etc/bknix-ci/install_all_publisher.sh ] && source /etc/bknix-ci/install_all_publisher.sh

  install_user
  install_ramdisk

  PROFILE=min HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8004 MEMCACHED_PORT=12224 PHPFPM_PORT=9012 REDIS_PORT=6383 MYSQLD_PORT=3310 install_profile

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE
}

###########################################################
## Install helpers

function install_user() {
  if id "$OWNER" 2>/dev/null 1>/dev/null ; then
    echo "User $OWNER already exists"
  else
    adduser --disabled-password "$OWNER"
  fi
}

function install_ramdisk() {
  echo "Creating systemd ramdisk \"$RAMDISK\" ($RAMDISKSVC)"
  template_render examples/systemd.mount > "/etc/systemd/system/${RAMDISKSVC}.mount"
  if [ -z "$NO_AUTOSTART" ]; then
    systemctl daemon-reload
    systemctl start "$RAMDISKSVC.mount"
    systemctl enable "$RAMDISKSVC.mount"
  fi
}

## Setup the binaries, data folder, and service for a given profile.
##
## Pre-condition:
##   PROFILE is a name like "min" or "max"
##   Optionally, HTTPD_PORT, MEMCACHED_PORT, PHPFPM_PORT, REDIS_PORT are set
function install_profile() {
  PRFDIR="/nix/var/nix/profiles/bknix-$PROFILE"
  BKNIXDIR="/home/$OWNER/bknix-$PROFILE"
  SYSTEMSVC="bknix-$PROFILE"
  if [ "$OWNER" != "jenkins" ]; then SYSTEMSVC="bknix-$OWNER-$PROFILE"; fi

  echo "Creating profile \"$PRFDIR\""
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$BKNIXDIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" HTTPD_DOMAIN=\"$HTTPD_DOMAIN\" HTTPD_PORT=\"$HTTPD_PORT\" HTTPD_VISIBILITY=\"$HTTPD_VISIBILITY\" HOSTS_TYPE=\"$HOSTS_TYPE\" MEMCACHED_PORT=\"$MEMCACHED_PORT\" MYSQLD_PORT=\"$MYSQLD_PORT\" PHPFPM_PORT=\"$PHPFPM_PORT\" REDIS_PORT=\"$REDIS_PORT\" \"$PRFDIR/bin/bknix\" init $FORCE_INIT"

  echo "Creating systemd services \"$SYSTEMSVC\" and \"$SYSTEMSVC-mysqld\""
  template_render examples/systemd.service > "/etc/systemd/system/${SYSTEMSVC}.service"
  template_render examples/systemd-mysqld.service > "/etc/systemd/system/${SYSTEMSVC}-mysqld.service"

  if [ -z "$NO_AUTOSTART" ]; then
    echo "Activating systemd services \"$SYSTEMSVC\" and \"bknix-$PROFILE-mysqld\""
    systemctl daemon-reload
    systemctl start "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
    systemctl enable "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
  fi
}

function template_render() {
  cat "$1" \
    | sed "s;%%RAMDISK%%;$RAMDISK;g" \
    | sed "s;%%RAMDISKSVC%%;$RAMDISKSVC;g" \
    | sed "s;%%RAMDISKSIZE%%;$RAMDISKSIZE;g" \
    | sed "s/%%OWNER%%/$OWNER/g" \
    | sed "s/%%PROFILE%%/$PROFILE/g"
}

function install_use_bknix() {
  echo "Installing global helper \"use-bknix\""
  cp -f bin/use-bknix /usr/local/bin/use-bknix
}

function install_warmup() {
  echo "Warming up binary cache"
  nix run --option binary-caches "https://bknix.think.hm/ https://cache.nixos.org" --option require-sigs false -f . dfl -c true
  nix run --option binary-caches "https://bknix.think.hm/ https://cache.nixos.org" --option require-sigs false -f . min -c true
  nix run --option binary-caches "https://bknix.think.hm/ https://cache.nixos.org" --option require-sigs false -f . max -c true
}

###########################################################
## Main

if [ -z `which nix` ]; then
  echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
  exit 2
fi

install_warmup
install_use_bknix
install_all_jenkins
# install_all_publisher
