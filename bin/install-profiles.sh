#!/bin/bash

# Install NixOS profile(s) for CiviCRM development. After installing, you can get access to a full
# LAMP-style CLI tool-chain by running of these statements:
#
#   export PATH=/nix/var/nix/profiles/bknix-min/bin:$PATH
#   export PATH=/nix/var/nix/profiles/bknix-max/bin:$PATH
#   export PATH=/nix/var/nix/profiles/bknix-dfl/bin:$PATH
#
# Pre-requisites:
#   Install the "nix" package manager.
#   Only tested with multiuser mode.
#
# Example: Install (or upgrade) all the profiles based on their master revision
#   sh <(curl https://raw.githubusercontent.com/totten/bknix/master/bin/install-profiles.sh)
#
# Example: Install (or upgrade) one specific profile (based on the master revision)
#   env PROFILES="dfl" sh <(curl https://raw.githubusercontent.com/totten/bknix/master/bin/install-profiles.sh)
#
# Example: Install (or upgrade) all the profiles defined in some other branch
#   env VERSION=someBranch sh <(curl https://raw.githubusercontent.com/totten/bknix/someBranch/bin/install-profiles.sh)

VERSION=${VERSION:-master}
PROFILES=${PROFILES:-min max dfl}
DEFN="${DEFN:-https://github.com/totten/bknix/archive/$VERSION.tar.gz}"

if [ -z `which nix` ]; then
  echo "Please install \"nix\" before running this. See: https://nixos.org/nix/manual/"
  exit 2
fi

for PROFILE in $PROFILES ; do
  PRFDIR="/nix/var/nix/profiles/bknix-$PROFILE"
  if [ -d "$PRFDIR" ]; then
    echo "Removing profile \"$PRFDIR\""
    sudo -i nix-env -p "$PRFDIR" -e '.*'
  fi
  echo "Creating profile \"$PRFDIR\" (version \"$VERSION\")"
  #sudo -i nix-env -i -p $PRFDIR -f "https://github.com/totten/bknix/archive/$VERSION.tar.gz" -E "f: f.profiles.$PROFILE"
  sudo -i nix-env -i -p "$PRFDIR" -f "$DEFN" -E "f: f.profiles.$PROFILE"
done
