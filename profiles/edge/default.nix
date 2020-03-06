/**
 * The `max` list identifies the highest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v18.09 (`pkgs`) and custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/18.09.nix) {};
    pkgs_1909 = import (import ../../pins/19.09.nix) {};
    bkpkgs = import ../../pkgs;
    base = import ../base/default.nix;
in base ++ [
    /* Custom programs */
    bkpkgs.launcher

    /* Major services */
    bkpkgs.php73
    pkgs.nodejs-8_x
    pkgs.apacheHttpd
    pkgs.memcached
    pkgs_1909.mysql80
    pkgs.redis

    /* CLI utilities */
    bkpkgs.transifexClient
]
