#!/bin/bash

# Install NixOS profile(s) for CiviCRM development. Setup a user with data folders.
#
# Pre-requisites:
#   Use a Debian-like main OS
#   Install the "nix" package manager.
#   Only tested with multiuser mode.
#
# Example: Install (or upgrade) all the profiles based on their master revision
#   ./bin/install-ci.sh
#
# Example: Install (or upgrade) one specific profile (based on the master revision)
#   env PROFILES="dfl" ./bin/install-ci.sh
#
# Example: Install (or upgrade) all the profiles defined in some other branch
#   env VERSION=someBranch ./bin/install-ci.sh

VERSION=${VERSION:-master}
PROFILES=${PROFILES:-min max dfl}
OWNER=${OWNER:-bknix}

if [ -z `which nix` ]; then
  echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
  exit 2
fi

if id "$OWNER" 2>/dev/null 1>/dev/null ; then
  echo "User $OWNER already exists"
else
  adduser --disabled-password "$OWNER"
fi

for PROFILE in $PROFILES ; do
  PRFDIR="/nix/var/nix/profiles/bknix-$PROFILE"
  DATADIR="/home/$OWNER/bknix-$PROFILE"

  echo "Creating profile \"$PRFDIR\" (version \"$VERSION\")"
  sudo -i nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$DATADIR\" for  profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$DATADIR\" \"$PRFDIR/bin/bknix\" init"
  mkdir -p "$DATADIR/build"
  chmod 1777 "$DATADIR/build"

  echo "Installing systemd service"
  cat examples/systemd.service \
    | sed "s/%%OWNER%%/$OWNER/" \
    | sed "s/%%PROFILE%%/$PROFILE/" \
    > "/etc/systemd/system/bknix-$PROFILE.service"

done
