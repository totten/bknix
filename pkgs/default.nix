/**
 * Provide a list of packages which we have defined or customized locally.
 *
 * TODO: Consider using callPackages convention, e.g. http://lethalman.blogspot.com/2014/09/nix-pill-13-callpackage-design-pattern.html
 */

let

  pkgs = import (import ../pins/18.09.nix) {};
  stdenv = pkgs.stdenv;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) pkgs) // overrides);

in rec {
   mysql55 = (import ./mysql55/default.nix).mysql55;
   php56 = import ./php56/default.nix;
   php70 = import ./php70/default.nix;
   ## Not used, don't waste any build-time on it ## php71 = import ./php71/default.nix;
   php72 = import ./php72/default.nix;
   transifexClient = import ./transifexClient/default.nix;
   ramdisk = callPackage (fetchTarball https://github.com/totten/ramdisk/archive/7a24b2d9ca0b64bbb063b51669d710d384b32616.tar.gz) {};
   loco = callPackage (fetchTarball https://github.com/totten/loco/archive/v0.1.1.tar.gz) {};
   launcher = import ./launcher;
}
