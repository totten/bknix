/**
 * Provide a list of packages which we have defined or customized locally.
 */
rec {
   /* NOT WORKING: php55 = import ./php55/default.nix; */
   php56 = import ./php56/default.nix;
   php70 = import ./php70/default.nix;
   php71 = import ./php71/default.nix;
   php72 = import ./php72/default.nix;
   launcher = import ./launcher;
}
