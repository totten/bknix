/**
 * Provide a list of packages which we have defined or customized locally.
 *
 * TODO: Consider using callPackages convention, e.g. http://lethalman.blogspot.com/2014/09/nix-pill-13-callpackage-design-pattern.html
 */
rec {
   mysql55 = (import ./mysql55/default.nix).mysql55;
   php56 = import ./php56/default.nix;
   php70 = import ./php70/default.nix;
#   php71 = import ./php71/default.nix;
   php72 = import ./php72/default.nix;
   transifexClient = import ./transifexClient/default.nix;
   launcher = import ./launcher;
}
