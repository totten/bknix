/**
 * The `max` list identifies the highest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v18.09 (`pkgs`) and custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/18.09.nix) {};
    bkpkgs = import ../../pkgs;
    baseProfile = import ../base/default.nix;
in baseProfile ++ [
    /* Custom programs */
    bkpkgs.launcher

    /* Major services */
    bkpkgs.php72
    pkgs.nodejs-8_x
    pkgs.apacheHttpd
    pkgs.memcached
    pkgs.mysql57
    pkgs.redis

    /* CLI utilities */
    bkpkgs.transifexClient
]
