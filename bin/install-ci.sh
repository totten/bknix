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
# Example: Install (or upgrade) all the profiles based on their master revision
#   ./bin/install-ci.sh
#
# Example: Install (or upgrade) all the profiles defined in some other branch
#   env VERSION=someBranch ./bin/install-ci.sh
#
# After installation, an automated script can use a statement like:
#    eval $(use-ci-bknix min)
#    eval $(use-ci-bknix max)
#    eval $(use-ci-bknix dfl)

VERSION=${VERSION:-master}
OWNER=${OWNER:-bknix}

## Setup the binaries, data folder, and service for a given profile.
##
## Pre-condition:
##   PROFILE is a name like "min" or "max"
##   Optionally, HTTPD_PORT, MEMCACHE_PORT, PHPFPM_PORT, REDIS_PORT are set
function install_profile() {
  PRFDIR="/nix/var/nix/profiles/bknix-$PROFILE"
  BKNIXDIR="/home/$OWNER/bknix-$PROFILE"

  echo "Creating profile \"$PRFDIR\" (version \"$VERSION\")"
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$BKNIXDIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$BKNIXDIR\" \"$PRFDIR/bin/bknix\" init"

  echo "Installing systemd service \"bknix-$PROFILE\""
  cat examples/systemd.service \
    | sed "s/%%OWNER%%/$OWNER/" \
    | sed "s/%%PROFILE%%/$PROFILE/" \
    > "/etc/systemd/system/bknix-$PROFILE.service"
  systemctl daemon-reload

  # FIXME: By default, the configurations have conflicted port allocations.
  # systemctl start "bknix-$PROFILE"
  # systemctl enable "bknix-$PROFILE"
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
PROFILE=dfl HTTPD_PORT=8001 MEMCACHE_PORT=12221 PHPFPM_PORT=9009 REDIS_PORT=6380 install_profile
PROFILE=min HTTPD_PORT=8002 MEMCACHE_PORT=12222 PHPFPM_PORT=9010 REDIS_PORT=6381 install_profile
PROFILE=max HTTPD_PORT=8003 MEMCACHE_PORT=12223 PHPFPM_PORT=9011 REDIS_PORT=6382 install_profile

echo "Installing global helper \"use-ci-bknix\""
cp -f bin/use-ci-bknix /usr/local/bin/use-ci-bknix

## FIXME: Shouldn't be necessary once we call "systemctl start" (etc)
echo "Please start and enable one of the systemd services, e.g."
echo "  systemctl start bknix-dfl"
echo "  systemctl enable bknix-dfl"
