#!/bin/bash

###########################################################
## Install helpers

function install_use_bknix() {
  echo "Installing global helper \"use-bknix\" (/usr/local/bin/use-bknix)"
  [ ! -d /usr/local/bin ] && sudo mkdir /usr/local/bin
  sudo cp -f bin/use-bknix.loco /usr/local/bin/use-bknix
}
