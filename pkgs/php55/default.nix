# THIS IS NOT WORKING (at least, on Darwin 16.7)
#
#
# Make an own version of php with the new php.ini from above
# add all extensions needed as buildInputs and don't forget to load them in the php.ini above

let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-16.03.tar.gz) {
      config = {
        php = {
          mysqlnd = true;
          ldap = false; /* FIXME: OK for Linux(?), but not for Darwin */
          imap = false; /* FIXME: OK for Linux(?), but not for Darwin */
          apxs2 = false; /* FIXME: OK for Linux(?), but not for Darwin */
          mssql = false; /* FIXME: OK for Linux(?), but not for Darwin */
        };
      };
    };

    stdenv = pkgs.stdenv;

    phpRuntime = pkgs.php55;
    phpPkgs = pkgs.php55Packages;

    phpIniSnippet = ./etc/php.ini;
    phpIni = pkgs.runCommand "php.ini"
    { options = ''
            zend_extension=${phpPkgs.xdebug}/lib/php/extensions/xdebug.so
      '';
/*
            extension=${phpPkgs.redis}/lib/php/extensions/redis.so
            extension=${phpPkgs.apcu}/lib/php/extensions/apcu.so
            extension=${phpPkgs.memcache}/lib/php/extensions/memcache.so
            extension=${phpPkgs.memcached}/lib/php/extensions/memcached.so
            extension=${phpPkgs.imagick}/lib/php/extensions/imagick.so
*/
    }
    ''
      cat "${phpRuntime}/etc/php.ini" > $out
      echo "$options" >> $out
      cat "${phpIniSnippet}" >> $out
    '';

    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php55";
        # buildInputs = [phpRuntime phpPkgs.xdebug phpPkgs.redis phpPkgs.apcu phpPkgs.memcached phpPkgs.memcache phpPkgs.imagick pkgs.makeWrapper];
        buildInputs = [phpRuntime phpPkgs.xdebug pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${phpRuntime}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
          makeWrapper ${phpRuntime}/bin/php-fpm $out/bin/php-fpm --add-flags -c --add-flags "${phpIni}"
        '';
        shellHook = ''
          export PATH="$src/bin:$PATH"
        '';
    };

in phpOverride
