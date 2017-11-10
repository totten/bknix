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
}
