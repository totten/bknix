/**
 * The `min` list identifies the lowest recommended versions of the system requirements.
 */
let
    pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {};
    bkpkgs = import ../../pkgs;
in [
    /* Custom programs */
    bkpkgs.launcher

    /* Major services */
    bkpkgs.php56
    pkgs.nodejs-6_x
    pkgs.apacheHttpd
    pkgs.memcached
    bkpkgs.mysql55
    pkgs.redis

    /* CLI utilities */
    pkgs.bzip2
    pkgs.curl
    pkgs.git
    pkgs.gnutar
    pkgs.rsync
    pkgs.unzip
    pkgs.zip
]
