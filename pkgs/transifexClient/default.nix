# with import <nixpkgs> {};
with import (import ../../pins/18.09.nix) {};
with python36.pkgs;

let

  slugify = callPackage ./slugify.nix {};
  requests = callPackage ./requests.nix {
     python = python36;
  };
  transifexClient = callPackage ./transifexClient.nix {
    python = python36;
    slugify = slugify;
    requests = requests;
  };

in transifexClient
