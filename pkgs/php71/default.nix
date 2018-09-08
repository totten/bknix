# Make an own version of php with the new php.ini from above
# add all extensions needed as buildInputs and don't forget to load them in the php.ini above

let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {
      config = {
        php = {
          mysqlnd = true;
        };
      };
    };

    stdenv = pkgs.stdenv;

    phpRuntime = pkgs.php71;
    phpPkgs = pkgs.php71Packages;

    phpIniSnippet = ./etc/php.ini;
    phpIni = pkgs.runCommand "php.ini"
    { options = ''
            zend_extension=${phpPkgs.xdebug}/lib/php/extensions/xdebug.so
            extension=${phpPkgs.redis}/lib/php/extensions/redis.so
            extension=${phpPkgs.memcached}/lib/php/extensions/memcached.so
            extension=${phpPkgs.imagick}/lib/php/extensions/imagick.so
      '';
    }
    ''
      cat "${phpRuntime}/etc/php.ini" > $out
      echo "$options" >> $out
      cat "${phpIniSnippet}" >> $out
    '';

    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php71";
        buildInputs = [phpRuntime phpPkgs.xdebug phpPkgs.redis phpPkgs.memcached phpPkgs.imagick pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${phpRuntime}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
          makeWrapper ${phpRuntime}/bin/php-fpm $out/bin/php-fpm --add-flags -c --add-flags "${phpIni}"
        '';
    };

in phpOverride
