/**
 * The `min` list identifies the lowest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v18.03 (`pkgs`) and custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/18.03.nix) {};
    pkgs_1809 = import (import ../../pins/18.09.nix) {};
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
    pkgs_1809.hostname
    pkgs.ncurses
    pkgs.patch
    pkgs.rsync
    pkgs.unzip
    pkgs.which
    pkgs.zip
    bkpkgs.transifexClient
]
