/**
 * The `dfl` list identifies the lowest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v19.09 (`pkgs`), v18.09 (`pkgs_1809`), and
 * custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/19.09.nix) {};
    pkgs_1809 = import (import ../../pins/18.09.nix) {};
    bkpkgs = import ../../pkgs;
    base = import ../base/default.nix;
in base ++ [
    /* Custom programs */
    bkpkgs.launcher
    bkpkgs.bknixPhpstormAdvisor

    /* Major services */
    bkpkgs.php71
    pkgs_1809.nodejs-8_x
    pkgs.apacheHttpd
    pkgs_1809.mailcatcher
    pkgs.memcached
    pkgs_1809.mysql57
    pkgs.redis

    /* CLI utilities */
    bkpkgs.loco
    bkpkgs.ramdisk
    bkpkgs.transifexClient
]
