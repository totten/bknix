with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    nodejs-4_x
    curl
    mysql55
    php56
    apacheHttpd
  ];

  shellHook = ''
    export BKNXAUTH=JoP1GUxV
    export PATH="$PWD/bin:$PATH"
    export AMPHOME=$PWD/var/amp
    export MYSQL_HOME=$PWD/var/mysql/conf
    alias ls='ls --color=auto'
    alias lsc='ls --color=auto -F'
    alias lsx='ls --color=auto -lF'
    bkctl init
  '';
}
