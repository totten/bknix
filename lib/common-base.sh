#!/bin/bash

###########################################################

# Current v2.2.1 suffers https://github.com/NixOS/nix/issues/2633 (eg on Debain Stretch/gcloud). Use v2.0.4.
# But 2.0.4 may not be working on macOS Mojave. Blerg.
NIX_INSTALLER_URL="https://nixos.org/releases/nix/nix-2.0.4/install"
# NIX_INSTALLER_URL="https://nixos.org/releases/nix/nix-2.2.1/install"

###########################################################
## Primary install routines

function install_nix_single() {
  if [ -d /nix ]; then
    return
  fi

  if [ -z "$(which curl)" ]; then
    echo "Missing required program: curl" >&2
    exit 1
  fi

  echo "Creating /nix ( https://nixos.org/nix/about.html ). This folder will store any new software in separate folder:"
  echo "This will be installed in single-user mode to allow the easiest administration."
  echo
  echo "Running: sh <(curl $NIX_INSTALLER_URL) --no-daemon"
  sh <(curl $NIX_INSTALLER_URL) --no-daemon

  if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
}

function install_warmup() {
  if [ -f /etc/nix/nix.conf ]; then
    if grep -q bknix.cachix.org /etc/nix/nix.conf ; then
      return
    fi
  fi
  echo "Setup binary cache"
  nix-env -iA cachix -f https://cachix.org/api/v1/install
  cachix use bknix
}

###########################################################
## Install helpers

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

function template_render() {
  cat "$1" \
    | sed "s;%%RAMDISK%%;$RAMDISK;g" \
    | sed "s;%%RAMDISKSVC%%;$RAMDISKSVC;g" \
    | sed "s;%%RAMDISKSIZE%%;$RAMDISKSIZE;g" \
    | sed "s/%%OWNER%%/$OWNER/g" \
    | sed "s/%%PROFILE%%/$PROFILE/g"
}
