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
#    eval $(use-ci-bknix min)
#    eval $(use-ci-bknix max)
#    eval $(use-ci-bknix dfl)

OWNER=${OWNER:-bknix}

## Setup the binaries, data folder, and service for a given profile.
##
## Pre-condition:
##   PROFILE is a name like "min" or "max"
##   Optionally, HTTPD_PORT, MEMCACHED_PORT, PHPFPM_PORT, REDIS_PORT are set
function install_profile() {
  PRFDIR="/nix/var/nix/profiles/bknix-$PROFILE"
  BKNIXDIR="/home/$OWNER/bknix-$PROFILE"

  echo "Creating profile \"$PRFDIR\""
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$BKNIXDIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" HTTPD_DOMAIN=\"$HTTPD_DOMAIN\" HTTPD_PORT=\"$HTTPD_PORT\" MEMCACHED_PORT=\"$MEMCACHED_PORT\" PHPFPM_PORT=\"$PHPFPM_PORT\" REDIS_PORT=\"$REDIS_PORT\" \"$PRFDIR/bin/bknix\" init $FORCE_INIT"

  echo "Installing systemd service \"bknix-$PROFILE\""
  cat examples/systemd.service \
    | sed "s/%%OWNER%%/$OWNER/" \
    | sed "s/%%PROFILE%%/$PROFILE/" \
    > "/etc/systemd/system/bknix-$PROFILE.service"
  systemctl daemon-reload
  systemctl start "bknix-$PROFILE"
  systemctl enable "bknix-$PROFILE"
}

if [ -z `which nix` ]; then
  echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
  exit 2
fi

if id "$OWNER" 2>/dev/null 1>/dev/null ; then
  echo "User $OWNER already exists"
else
  adduser --disabled-password "$OWNER"
fi

## Install each profile
PROFILE=dfl HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8001 MEMCACHED_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 install_profile
PROFILE=min HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8002 MEMCACHED_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 install_profile
PROFILE=max HTTPD_DOMAIN=$(hostname -f) HTTPD_PORT=8003 MEMCACHED_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 install_profile

echo "Installing global helper \"use-ci-bknix\""
cp -f bin/use-ci-bknix /usr/local/bin/use-ci-bknix
