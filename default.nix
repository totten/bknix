with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    nodejs-6_x
    curl
    mysql55
    php56
    apacheHttpd
  ];

  shellHook = ''
    export BKNIXDIR="$PWD"
    export PATH="$BKNIXDIR/bin:$BKNIXDIR/civicrm-buildkit/bin:$PATH"
    export AMPHOME="$BKNIXDIR/var/amp"
    export MYSQL_HOME="$BKNIXDIR/var/mysql/conf"
    alias ls='ls --color=auto'
    alias lsc='ls --color=auto -F'
    alias lsx='ls --color=auto -lF'
    bknix init
  '';
}
