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
    phpVer = "php56";
    phpXxx = builtins.getAttr phpVer pkgs;
    phpXxxPkgs = builtins.getAttr "${phpVer}Packages" pkgs;

    phpIniSnippet = ./etc/php.ini;
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

    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php-override";
        buildInputs = [phpXxx phpXxxPkgs.xdebug phpXxxPkgs.redis phpXxxPkgs.apcu phpXxxPkgs.memcached phpXxxPkgs.memcache phpXxxPkgs.imagick pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${phpXxx}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
          makeWrapper ${phpXxx}/bin/php-fpm $out/bin/php-fpm --add-flags -c --add-flags "${phpIni}"
        '';
        shellHook = ''
          export PATH="$src/bin:$PATH"
        '';
    };

in phpOverride

/*
  
  stdenv.mkDerivation rec {
    name = "php56";
    buildInputs = [ phpOverride phpXxx ];
    buildCommand = ''
      mkdir "$out"
    '';
  };
}
*/