#!/bin/bash

###########################################################
## Primary install routines

## Setup all services for user "jenkins"
function install_all_jenkins() {
  OWNER=jenkins
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=8G

  [ -f /etc/bknix-ci/install_all_jenkins.sh ] && source /etc/bknix-ci/install_all_jenkins.sh

  install_user
  install_ramdisk

  PROFILE=dfl HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8001 MEMCACHED_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 MYSQLD_PORT=3307 install_profile
  PROFILE=min HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8002 MEMCACHED_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 MYSQLD_PORT=3308 install_profile
  PROFILE=max HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8003 MEMCACHED_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 MYSQLD_PORT=3309 install_profile
  #EDGE# PROFILE=edge HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8004 MEMCACHED_PORT=12224 PHPFPM_PORT=9012 REDIS_PORT=6383 MYSQLD_PORT=3310 install_profile
  #OLD#  PROFILE=old  HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8005 MEMCACHED_PORT=12225 PHPFPM_PORT=9013 REDIS_PORT=6384 MYSQLD_PORT=3311 install_profile

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE
}

## Setup all services for user "publisher"
function install_all_publisher() {
  OWNER=publisher
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=500M

  [ -f /etc/bknix-ci/install_all_publisher.sh ] && source /etc/bknix-ci/install_all_publisher.sh

  install_user
  install_ramdisk

  PROFILE=min HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8004 MEMCACHED_PORT=12224 PHPFPM_PORT=9012 REDIS_PORT=6383 MYSQLD_PORT=3310 install_profile
  PROFILE=old HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8005 MEMCACHED_PORT=12225 PHPFPM_PORT=9013 REDIS_PORT=6384 MYSQLD_PORT=3311 install_profile

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE
}

###########################################################
## Install helpers

function install_nix_single() {
  if [ -d /nix ]; then
    return
  fi

  if [ -z "$(which curl)" ]; then
    echo "Missing required program: curl" >&2
    exit 1
  fi

  local mode
  mode="--no-daemon"

  echo "Creating /nix ( https://nixos.org/nix/about.html ). This folder will store any new software in separate folder:"
  echo "This will be installed in single-user mode to allow the easiest administration."
  echo
  echo "Running: sh <(curl https://nixos.org/nix/install) $mode"
  sh <(curl https://nixos.org/nix/install) $mode

  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
}

function check_reqs() {
  if [ -z `which nix` ]; then
   echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
    exit 2
  fi
}

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
  systemctl daemon-reload
  systemctl start "$RAMDISKSVC.mount"
  systemctl enable "$RAMDISKSVC.mount"
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
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" HTTPD_DOMAIN=\"$HTTPD_DOMAIN\" HTTPD_PORT=\"$HTTPD_PORT\" MEMCACHED_PORT=\"$MEMCACHED_PORT\" MYSQLD_PORT=\"$MYSQLD_PORT\" PHPFPM_PORT=\"$PHPFPM_PORT\" REDIS_PORT=\"$REDIS_PORT\" \"$PRFDIR/bin/bknix\" init $FORCE_INIT"

  echo "Creating systemd services \"$SYSTEMSVC\" and \"$SYSTEMSVC-mysqld\""
  template_render examples/systemd.service > "/etc/systemd/system/${SYSTEMSVC}.service"
  template_render examples/systemd-mysqld.service > "/etc/systemd/system/${SYSTEMSVC}-mysqld.service"

  echo "Activating systemd services \"$SYSTEMSVC\" and \"bknix-$PROFILE-mysqld\""
  systemctl daemon-reload
  systemctl start "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
  systemctl enable "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
}

## Install just the binaries for a profile
## Pre-condition:
##   PROFILE is a name like "min" or "max"
##   USER is the current user
function install_user_profile_binaries() {
  local PRFDIR
  PRFDIR="/nix/var/nix/profiles/per-user/$USER/bknix-$PROFILE"

  if [ -d "$PRFDIR" ]; then
    echo "Removing profile \"$PRFDIR\""
    nix-env -p "$PRFDIR" -e '.*'
  fi

  echo "Creating profile \"$PRFDIR\""
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"
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
  echo "Installing global helper \"use-bknix\" (/usr/local/bin/use-bknix)"
  [ ! -d /usr/local/bin ] && sudo mkdir /usr/local/bin
  sudo cp -f bin/use-bknix /usr/local/bin/use-bknix
}

function install_warmup() {
  if grep -q bknix.cachix.org /etc/nix/nix.conf ; then
    return
  fi
  echo "Setup binary cache"
  nix-env -iA cachix -f https://cachix.org/api/v1/install
  cachix use bknix
}
