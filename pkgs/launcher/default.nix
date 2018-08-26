let

    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {};
    stdenv = pkgs.stdenv;

in stdenv.mkDerivation rec {

    name = "launcher";
    src = ./src;
    installPhase = ''
        mkdir -p $out/bin
        cp $src/bkrun $out/bin/bkrun
        cp $src/bknix $out/bin/bknix
    '';

    ## We don't delcare an official dependency on PHP because there are
    ## multiple versions in this repo, and we want to be able to
    ## mix/match.
}
