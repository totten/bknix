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
#   ./bin/install-ci.sh
#
# Example: Install (or upgrade) all the profiles, overwriting any local config files
#   FORCE_INIT=-f ./bin/install-ci.sh
#
# After installation, an automated script can use a statement like:
#    eval $(use-bknix min)
#    eval $(use-bknix max)
#    eval $(use-bknix dfl)

OWNER=${OWNER:-bknix}
RAMDISK="/mnt/mysql/$OWNER"
RAMDISKSVC=$(systemd-escape "mnt/mysql/$OWNER")

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

  echo "Creating profile \"$PRFDIR\""
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$BKNIXDIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" HTTPD_DOMAIN=\"$HTTPD_DOMAIN\" HTTPD_PORT=\"$HTTPD_PORT\" MEMCACHED_PORT=\"$MEMCACHED_PORT\" PHPFPM_PORT=\"$PHPFPM_PORT\" REDIS_PORT=\"$REDIS_PORT\" \"$PRFDIR/bin/bknix\" init $FORCE_INIT"

  echo "Creating systemd service \"bknix-$PROFILE\""
  template_render examples/systemd.service > "/etc/systemd/system/${SYSTEMSVC}.service"

  echo "Activating systemd service \"$SYSTEMSVC\""
  systemctl daemon-reload
  systemctl start "$SYSTEMSVC"
  systemctl enable "$SYSTEMSVC"
}

function template_render() {
  cat "$1" \
    | sed "s;%%RAMDISK%%;$RAMDISK;g" \
    | sed "s;%%RAMDISKSVC%%;$RAMDISKSVC;g" \
    | sed "s/%%OWNER%%/$OWNER/g" \
    | sed "s/%%PROFILE%%/$PROFILE/g"
}

########################################
## Main

if [ -z `which nix` ]; then
  echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
  exit 2
fi

if id "$OWNER" 2>/dev/null 1>/dev/null ; then
  echo "User $OWNER already exists"
else
  adduser --disabled-password "$OWNER"
fi

echo "Installing global helper \"use-bknix\""
cp -f bin/use-bknix /usr/local/bin/use-bknix

install_ramdisk

PROFILE=dfl HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8001 MEMCACHED_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 install_profile
PROFILE=min HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8002 MEMCACHED_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 install_profile
PROFILE=max HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8003 MEMCACHED_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 install_profile
