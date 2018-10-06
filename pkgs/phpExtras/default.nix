/**
 * phpExtras is a library of supplemental PECL extensions. These extensions
 * aren't defined in <nixpkgs>
 */

{ pkgs, php }:

let

  buildPecl = import ./build-pecl.nix {
    inherit php;
    inherit (pkgs) stdenv autoreconfHook fetchurl;
  };

in rec {

  timecop = buildPecl {
    name = "timecop-1.2.10";
    sha256 = "1c74k2dmpi9naipsnagrqcaxii2h82m2mhdrxgdalrshgkpv0vdh";
    configureFlags = [ ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ ];
  };

}
