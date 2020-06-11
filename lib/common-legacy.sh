#!/bin/bash

###########################################################
## Primary install routines

## Setup all services for user "jenkins"
function install_all_jenkins() {
  OWNER=jenkins
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=8G
  PROFILES=${PROFILES:-dfl min max}
  HTTPD_DOMAIN=$(hostname -f)

  [ -f /etc/bknix-ci/install_all_jenkins.sh ] && source /etc/bknix-ci/install_all_jenkins.sh

  install_user
  install_ramdisk

  for PROFILE in $PROFILES ; do
    case "$PROFILE" in
      dfl) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8001 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 MYSQLD_PORT=3307 install_profile ; ;;
      min) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8002 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 MYSQLD_PORT=3308 install_profile ; ;;
      max) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8003 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 MYSQLD_PORT=3309 install_profile ; ;;
      old) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8006 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12226 PHPFPM_PORT=9014 REDIS_PORT=6385 MYSQLD_PORT=3312 install_profile ; ;;
      edge) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8007 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12227 PHPFPM_PORT=9015 REDIS_PORT=6386 MYSQLD_PORT=3313 install_profile ; ;;
    esac
  done

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE PROFILES PROFILE HTTPD_DOMAIN
}

## Setup all services for user "publisher"
function install_all_publisher() {
  OWNER=publisher
  RAMDISK="/mnt/mysql/$OWNER"
  RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")
  RAMDISKSIZE=500M
  PROFILES=""
  HTTPD_DOMAIN=$(hostname -f)

  [ -f /etc/bknix-ci/install_all_publisher.sh ] && source /etc/bknix-ci/install_all_publisher.sh

  install_user
  install_ramdisk

  for PROFILE in $PROFILES ; do
    case "$PROFILE" in
      min) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8004 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12224 PHPFPM_PORT=9012 REDIS_PORT=6383 MYSQLD_PORT=3310 install_profile ; ;;
      old) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8005 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12225 PHPFPM_PORT=9013 REDIS_PORT=6384 MYSQLD_PORT=3311 install_profile ; ;;
      max) HTTPD_DOMAIN=${HTTPD_DOMAIN:-localhost} HTTPD_PORT=8008 HTTPD_VISIBILITY=all HOSTS_TYPE=none MEMCACHED_PORT=12228 PHPFPM_PORT=9016 REDIS_PORT=6387 MYSQLD_PORT=3314 install_profile ; ;;
    esac
  done

  unset OWNER RAMDISK RAMDISKSVC RAMDISKSIZE PROFILES PROFILE HTTPD_DOMAIN
}

###########################################################
## Install helpers

function check_reqs() {
  if [ -z `which nix` ]; then
   echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
    exit 2
  fi
}

## usage: init_folder <src-folder> <tgt-folder>
## If the target folder doesn't exist, create it (by copying the source folder).
## ex: init_folder "$PWD/examples/gcloud-bknix-ci" "/etc/bknix-ci"
function init_folder() {
  local src="$1"
  local tgt="$2"
  if [ -d "$tgt" ]; then
    echo "Found $tgt"
    return
  fi

  echo "Initializing $tgt ($src)"
  cp -r "$src" "$tgt"
}

function install_user() {
  if id "$OWNER" 2>/dev/null 1>/dev/null ; then
    echo "User $OWNER already exists"
  else
    adduser --disabled-password "$OWNER"
  fi
}

function install_ramdisk() {
  if [ -z "$NO_SYSTEMD" ]; then
    echo "Creating systemd ramdisk \"$RAMDISK\" ($RAMDISKSVC)"
    template_render examples/systemd.mount > "/etc/systemd/system/${RAMDISKSVC}.mount"
    systemctl daemon-reload
    systemctl start "$RAMDISKSVC.mount"
    systemctl enable "$RAMDISKSVC.mount"
  else
    echo "Skip: Creating systemd ramdisk \"$RAMDISK\" ($RAMDISKSVC)"
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

  if [ -d "$PRFDIR" ]; then
    echo "Removing profile \"$PRFDIR\""
    $SUDO nix-env -p "$PRFDIR" -e '.*'
  fi

  echo "Creating profile \"$PRFDIR\""
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$BKNIXDIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" HTTPD_DOMAIN=\"$HTTPD_DOMAIN\" HTTPD_PORT=\"$HTTPD_PORT\" HTTPD_VISIBILITY=\"$HTTPD_VISIBILITY\" HOSTS_TYPE=\"$HOSTS_TYPE\" MEMCACHED_PORT=\"$MEMCACHED_PORT\" MYSQLD_PORT=\"$MYSQLD_PORT\" PHPFPM_PORT=\"$PHPFPM_PORT\" REDIS_PORT=\"$REDIS_PORT\" \"$PRFDIR/bin/bknix\" init $FORCE_INIT"

  if [ -z "$NO_SYSTEMD" ]; then
    echo "Creating systemd services \"$SYSTEMSVC\" and \"$SYSTEMSVC-mysqld\""
    template_render examples/systemd.service > "/etc/systemd/system/${SYSTEMSVC}.service"
    template_render examples/systemd-mysqld.service > "/etc/systemd/system/${SYSTEMSVC}-mysqld.service"

    echo "Activating systemd services \"$SYSTEMSVC\" and \"$SYSTEMSVC-mysqld\""
    systemctl daemon-reload
    systemctl start "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
    systemctl enable "$SYSTEMSVC" "$SYSTEMSVC-mysqld"
  else
    echo "Skip: Creating/activating systemd services \"$SYSTEMSVC\" and \"bknix-$PROFILE-mysqld\""
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
  cp -f bin/use-bknix.legacy /usr/local/bin/use-bknix
}

function install_warmup() {
  echo "Setup binary cache"
  nix-env -iA cachix -f https://cachix.org/api/v1/install
  cachix use bknix
}
