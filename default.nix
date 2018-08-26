let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {
      config = {
        php = {
          mysqlnd = true;
        };
      };
    };

    stdenv = pkgs.stdenv;
    phpIniSnippet = ./config/php.ini;
    phpIni = pkgs.runCommand "php.ini"
    { options = ''
            zend_extension=${pkgs.php56Packages.xdebug}/lib/php/extensions/xdebug.so
            extension=${pkgs.php56Packages.redis}/lib/php/extensions/redis.so
            extension=${pkgs.php56Packages.apcu}/lib/php/extensions/apcu.so
            extension=${pkgs.php56Packages.memcache}/lib/php/extensions/memcache.so
            extension=${pkgs.php56Packages.memcached}/lib/php/extensions/memcached.so
            extension=${pkgs.php56Packages.imagick}/lib/php/extensions/imagick.so
      '';
    }
    ''
      cat "${pkgs.php56}/etc/php.ini" > $out
      echo "$options" >> $out
      cat "${phpIniSnippet}" >> $out
    '';

    # make an own version of php with the new php.ini from above
    # add all extensions needed as buildInputs and don't forget to load them in the php.ini above
    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php-override";
        buildInputs = [pkgs.php56 pkgs.php56Packages.xdebug pkgs.php56Packages.redis pkgs.php56Packages.apcu pkgs.php56Packages.memcached pkgs.php56Packages.memcache pkgs.php56Packages.imagick pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${pkgs.php56}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
          makeWrapper ${pkgs.php56}/bin/php-fpm $out/bin/php-fpm --add-flags -c --add-flags "${phpIni}"
        '';
    };

in stdenv.mkDerivation rec {
        name = "bknix";
        src = ./bin;
        installPhase = ''
          mkdir -p $out/bin
          cp $src/bkrun $out/bin/bkrun
          cp $src/bknix $out/bin/bknix
        '';
        buildInputs = [
            phpOverride
            pkgs.php56
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
