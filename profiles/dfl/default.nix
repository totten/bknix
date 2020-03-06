/**
 * The `dfl` list identifies the lowest recommended versions of the system requirements.
 *
 * We rely on a mix of packages from Nix upstream v18.03 (`pkgs`), v18.09 (`pkgs_1809`), and
 * custom forks (`bkpkgs`).
 */
let
    pkgs = import (import ../../pins/18.03.nix) {};
    pkgs_1809 = import (import ../../pins/18.09.nix) {};
    bkpkgs = import ../../pkgs;

in (import ../base/default.nix) ++ (import ../mgmt/default.nix) ++ [

    bkpkgs.php71
    pkgs.nodejs-8_x
    pkgs.apacheHttpd
    pkgs.memcached
    pkgs_1809.mysql57
    pkgs.redis
    bkpkgs.transifexClient

]
