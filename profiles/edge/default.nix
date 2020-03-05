/**
 * The `max` list identifies the highest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v19.09 (`pkgs`), v18.09 (`pkgs_1809`), and
 * custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/19.09.nix) {};
    pkgs_1809 = import (import ../../pins/18.09.nix) {};
    bkpkgs = import ../../pkgs;
in [
    /* Custom programs */
    bkpkgs.launcher
    bkpkgs.bknixPhpstormAdvisor

    /* Major services */
    bkpkgs.php73
    pkgs_1809.nodejs-8_x
    pkgs.apacheHttpd
    pkgs_1809.mailcatcher
    pkgs.memcached
    /* pkgs.mariadb */
    pkgs.mysql80
    pkgs.redis

    /* CLI utilities */
    bkpkgs.loco
    bkpkgs.ramdisk
    pkgs.bzip2
    pkgs.curl
    pkgs.gettext
    pkgs.git
    pkgs.gitAndTools.hub
    pkgs.gnugrep
    pkgs.gnutar
    pkgs.hostname
    pkgs.ncurses
    pkgs.patch
    pkgs.rsync
    pkgs.unzip
    pkgs.which
    pkgs.zip
    pkgs_1909.glibcLocales
    bkpkgs.transifexClient
]
