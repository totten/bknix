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

  ## Make a package by downloading a PHAR executable.
  makePhar = {name, url, sha256}: stdenv.mkDerivation rec {
    inherit name;
    fetchedItem = pkgs.fetchurl { inherit url sha256; executable = true; };
    buildCommand = ''
      mkdir $out $out/bin
      ln -s $fetchedItem $out/bin/$name
    '';
  };

in rec {
  mysql55 = (import ./mysql55/default.nix).mysql55;
  php56 = import ./php56/default.nix;
  php70 = import ./php70/default.nix;
  ## Not used, don't waste any build-time on it ## php71 = import ./php71/default.nix;
  php72 = import ./php72/default.nix;
  transifexClient = import ./transifexClient/default.nix;
  ramdisk = callPackage (fetchTarball https://github.com/totten/ramdisk/archive/7a24b2d9ca0b64bbb063b51669d710d384b32616.tar.gz) {};
  loco = callPackage (fetchTarball https://github.com/totten/loco/archive/v0.2.1.tar.gz) {};
  launcher = import ./launcher;

  amp =            (makePhar { name = "amp";                  url = https://download.civicrm.org/amp/amp.phar-2018-09-29-73136a8b;                   sha256 = "0xz7m6p6a1c9b45kr5g0knmlg0ciq01y3plnf6kkrcyavrfawj0v"; });
  box =            (makePhar { name = "box";                  url = https://github.com/box-project/box2/releases/download/2.7.5/box-2.7.5.phar;      sha256 = "1ky8rlh0nznwyllps7j6l7sz79wrn7jdds35lg90f0ycgag1xfc1"; });
  civici =         (makePhar { name = "civici";               url = https://download.civicrm.org/civici/civici-0.1.2.phar;                           sha256 = "0qclwg1yakij1jvlx67hshi79iil9blrmycshwvc6pb3q9cd6qa6"; });
  civistrings =    (makePhar { name = "civistrings";          url = https://download.civicrm.org/civistrings/civistrings.phar-2018-04-11-93987d92;   sha256 = "07z2i8pllcfz471h1ph4d3amnq9x6l4d5l1r3p097gs42mnlj0bh"; });
  civix =          (makePhar { name = "civix";                url = https://download.civicrm.org/civix/civix.phar-2018-12-04-1d9c1734;               sha256 = "0i9zr7mz5jabd253vi822ccv00kib8c9z80lk5ylcp47803mxcjm"; });
  cv =             (makePhar { name = "cv";                   url = https://download.civicrm.org/cv/cv.phar-2018-12-04-eefce0d0;                     sha256 = "183ymdbvm3ni932ilhsn41ykgx5s2is64p940ph8vvhrs34as8jz"; });
  drush8 =         (makePhar { name = "drush8";               url = https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar;          sha256 = "1gz75nrq3jvpvi9n453gfzkhfk7axix92961hvbi475k2984qs1d"; });
  git-scan =       (makePhar { name = "git-scan";             url = https://download.civicrm.org/git-scan/git-scan.phar-2017-06-28-101620c7;         sha256 = "02sdwrh0z5m17s6mkicj2kq3b044vsl921kllrpi63qrf7zklja1"; });
  joomla =         (makePhar { name = "joomla";               url = https://download.civicrm.org/joomlatools-console/joomla.phar-2017-06-19-62ff6a9df; sha256 = "03amn61aps8vyd21ssw8fz0ff3znjmkf95av35d65n0i0vbss3i3"; });
  phpunit4 =       (makePhar { name = "phpunit4";             url = https://phar.phpunit.de/phpunit-4.8.21.phar;                                     sha256 = "1yjkm44q11iyjymci785yms94p5qbfdwxz9gzsjsipgg0cv6zggq"; });
  phpunit5 =       (makePhar { name = "phpunit5";             url = https://phar.phpunit.de/phpunit-5.phar;                                          sha256 = "0nhr361k528q9spz0w0vx3s86rxpvzka5a0kx1x7g9iiias0zl4x"; });
  wp =             (makePhar { name = "wp";                   url = https://github.com/wp-cli/wp-cli/releases/download/v2.0.1/wp-cli-2.0.1.phar;     sha256 = "0qrbmlr876l76xqfvv6gypw9kvvla4r591yzp969y3bzi92xn0g3"; });

  ## FIXME
  #_codecept-php5.phar =   (makePhar { name = "_codecept-php5.phar";  url = http://codeception.com/releases/2.3.6/php54/codecept.phar;                       sha256 = "1zgx567dm15ldz6f7wa990p61xgmw7w85dqqgmdz8lid5fdbi9cf"; });
  #_codecept-php7.phar =   (makePhar { name = "_codecept-php7.phar";  url = http://codeception.com/releases/2.3.6/codecept.phar;                             sha256 = "0galyryymdl2b9kdz212d7f2dcv76xgjws6j4bihr23sacamd029"; });
}
