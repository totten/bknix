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
    export BKCTL=JoP1GUxV
    export PATH="$PWD/bin:$PATH"
    export AMPHOME=$PWD/var/amp
    export MYSQL_HOME=$PWD/etc/mysql
    bkctl init
  '';
}
