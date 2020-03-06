/**
 * The `min` list identifies the lowest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v19.09 (`pkgs`), v18.09 (`pkgs_1809`), and
 * custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/19.09.nix) {};
    pkgs_1809 = import (import ../../pins/18.09.nix) {};
    bkpkgs = import ../../pkgs;
    baseProfile = import ../base/default.nix;
in baseProfile ++ [
    /* Custom programs */
    bkpkgs.launcher
    bkpkgs.bknixPhpstormAdvisor

    /* Major services */
    bkpkgs.php70
    pkgs_1809.nodejs-8_x
    pkgs.apacheHttpd
    pkgs_1809.mailcatcher
    pkgs.memcached
    bkpkgs.mysql55
    pkgs.redis

    /* CLI utilities */
    bkpkgs.loco
    bkpkgs.ramdisk
    bkpkgs.transifexClient
]
