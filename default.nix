let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {};
    stdenv = pkgs.stdenv;

    bknixPhp56 = import ./pkgs/php56/default.nix;
    bknixPhp70 = import ./pkgs/php70/default.nix;
    bknixMgmt = import ./pkgs/launcher;

    commonConsoleTools = [
      bknixMgmt
      pkgs.curl
      pkgs.zip
      pkgs.unzip
      pkgs.git
    ];

in stdenv.mkDerivation rec {
        name = "bknix";
        buildInputs = commonConsoleTools ++ [
            bknixPhp56
            pkgs.nodejs-6_x
            pkgs.apacheHttpd
            pkgs.memcached
            pkgs.mysql57
            pkgs.redis
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
