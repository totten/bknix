let

    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {};
    stdenv = pkgs.stdenv;
    bkpkgs = import ./pkgs;

in stdenv.mkDerivation rec {

    name = "bknix";
    buildInputs = [
        bkpkgs.launcher
        bkpkgs.php56
        pkgs.nodejs-6_x
        pkgs.apacheHttpd
        pkgs.memcached
        pkgs.mysql57
        pkgs.redis
        pkgs.curl
        pkgs.zip
        pkgs.unzip
        pkgs.git
    ];

    buildCommand = ''
        mkdir $out
    '';

    shellHook = ''
        [ -z "$BKNIXDIR" ] && export BKNIXDIR="$PWD"
        export PATH="$BKNIXDIR/civicrm-buildkit/bin:$PATH"
        export AMPHOME="$BKNIXDIR/var/amp"
        export MYSQL_HOME="$BKNIXDIR/var/mysql/conf"

        if [ -f "$BKNIXDIR/config/bashrc.local" ]; then
          source "$BKNIXDIR/config/bashrc.local"
        fi
    '';

}
