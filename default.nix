let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {
      config = {
        php = {
          mysqlnd = true;
        };
      };
    };

    stdenv = pkgs.stdenv;
    phpXxx = pkgs.php56;
    phpXxxPkgs = pkgs.php56Packages;

    phpIniSnippet = ./config/php.ini;
    phpIni = pkgs.runCommand "php.ini"
    { options = ''
            zend_extension=${phpXxxPkgs.xdebug}/lib/php/extensions/xdebug.so
            extension=${phpXxxPkgs.redis}/lib/php/extensions/redis.so
            extension=${phpXxxPkgs.apcu}/lib/php/extensions/apcu.so
            extension=${phpXxxPkgs.memcache}/lib/php/extensions/memcache.so
            extension=${phpXxxPkgs.memcached}/lib/php/extensions/memcached.so
            extension=${phpXxxPkgs.imagick}/lib/php/extensions/imagick.so
      '';
    }
    ''
      cat "${phpXxx}/etc/php.ini" > $out
      echo "$options" >> $out
      cat "${phpIniSnippet}" >> $out
    '';

    # make an own version of php with the new php.ini from above
    # add all extensions needed as buildInputs and don't forget to load them in the php.ini above
    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php-override";
        buildInputs = [phpXxx phpXxxPkgs.xdebug phpXxxPkgs.redis phpXxxPkgs.apcu phpXxxPkgs.memcached phpXxxPkgs.memcache phpXxxPkgs.imagick pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${phpXxx}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
          makeWrapper ${phpXxx}/bin/php-fpm $out/bin/php-fpm --add-flags -c --add-flags "${phpIni}"
        '';
    };

    bknixMgmt = stdenv.mkDerivation rec {
        name = "bknix-mgmt";
        src = ./src/mgmt;
        installPhase = ''
          mkdir -p $out/bin
          cp $src/bkrun $out/bin/bkrun
          cp $src/bknix $out/bin/bknix
        '';
    };

in stdenv.mkDerivation rec {
        name = "bknix";
        buildInputs = [
            phpOverride
            bknixMgmt
            phpXxx
            pkgs.nodejs-6_x
            pkgs.curl
            pkgs.apacheHttpd
            pkgs.memcached
            pkgs.mysql57
            pkgs.redis
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
