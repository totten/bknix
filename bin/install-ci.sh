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
# Example: Install (or upgrade) one specific profile (based on the master revision)
#   env PROFILES="dfl" ./bin/install-ci.sh
#
# Example: Install (or upgrade) all the profiles defined in some other branch
#   env VERSION=someBranch ./bin/install-ci.sh
#
# After installation, an automated script can use a statement like:
#    eval $(use-ci-bknix min)
#    eval $(use-ci-bknix max)
#    eval $(use-ci-bknix dfl)

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
  nix-env -i -p "$PRFDIR" -f . -E "f: f.profiles.$PROFILE"

  echo "Initializing data \"$DATADIR\" for profile \"$PRFDIR\""
  sudo su - "$OWNER" -c "PATH=\"$PRFDIR/bin:$PATH\" BKNIXDIR=\"$DATADIR\" \"$PRFDIR/bin/bknix\" init"

  echo "Installing systemd service \"bknix-$PROFILE\""
  cat examples/systemd.service \
    | sed "s/%%OWNER%%/$OWNER/" \
    | sed "s/%%PROFILE%%/$PROFILE/" \
    > "/etc/systemd/system/bknix-$PROFILE.service"

done

echo "Installing global helper \"use-ci-bknix\""
cp -f bin/use-ci-bknix /usr/local/bin/use-ci-bknix

# FIXME: By default, the configurations have conflicted port allocations.
#echo "Activating systemd services"
systemctl daemon-reload
#for PROFILE in $PROFILES ; do
#  systemctl start "bknix-$PROFILE"
#  systemctl enable "bknix-$PROFILE"
#done
echo "Please start and enable one of the systemd services, e.g."
echo "  systemctl start bknix-dfl"
echo "  systemctl enable bknix-dfl"
