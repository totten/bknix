let
    pkgs = import <nixpkgs> {};
    stdenv = pkgs.stdenv;
    phpIni = pkgs.runCommand "php.ini"
    { options = ''
            zend_extension=${pkgs.php56Packages.xdebug}/lib/php/extensions/xdebug.so
            max_execution_time = 0
            xdebug.remote_autostart=on
            xdebug.remote_enable=on
            xdebug.remote_mode=req
            xdebug.remote_handler=dbgp
            xdebug.remote_host=localhost
            xdebug.remote_port=9001

            extension=${pkgs.php56Packages.redis}/lib/php/extensions/redis.so
            extension=${pkgs.php56Packages.imagick}/lib/php/extensions/imagick.so
      '';
    }
    ''
      cat "${pkgs.php56}/etc/php.ini" > $out
      echo "$options" >> $out
    '';

    # make an own version of php with the new php.ini from above
    # add all extensions needed as buildInputs and don't forget to load them in the php.ini above
    phpOverride = stdenv.mkDerivation rec {
        name = "bknix-php-override";
        buildInputs = [pkgs.php56 pkgs.php56Packages.xdebug pkgs.php56Packages.redis pkgs.php56Packages.imagick pkgs.makeWrapper];
        buildCommand = ''
          makeWrapper ${pkgs.php56}/bin/php $out/bin/php --add-flags -c --add-flags "${phpIni}"
        '';
    };
in rec {
    bknix = stdenv.mkDerivation rec {
        name = "bknix";
        buildInputs = [
            phpOverride
            pkgs.nodejs-6_x
            pkgs.curl
            pkgs.apacheHttpd
            pkgs.mysql55
        ];
        shellHook = ''
          export BKNIXDIR="$PWD"
          export PATH="$BKNIXDIR/bin:$BKNIXDIR/civicrm-buildkit/bin:$PATH"
          export AMPHOME="$BKNIXDIR/var/amp"
          export MYSQL_HOME="$BKNIXDIR/var/mysql/conf"
          bknix init

          alias ls='ls --color=auto'
          alias lsc='ls --color=auto -F'
          alias lsx='ls --color=auto -lF'
          alias rm='rm -i'
          alias mv='mv -i'
          alias cp='cp -i'
        '';
    };
}
