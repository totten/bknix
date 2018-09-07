/**
 * The `default` list identifies the lowest recommended versions of the system requirements.
 */
let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {};
    stdenv = pkgs.stdenv;
    bkpkgs = import ../../pkgs;

in [
    bkpkgs.launcher
    bkpkgs.php56
    pkgs.nodejs-6_x
    pkgs.apacheHttpd
    pkgs.memcached
    pkgs.mysql57
    pkgs.redis
    pkgs.curl
    pkgs.zip
    pkgs.unzip
    pkgs.git
]
