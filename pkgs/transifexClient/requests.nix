{ buildPythonPackage, fetchurl, stdenv, python }:

buildPythonPackage rec {

  name = "requests";

  src = fetchurl {
    url = "https://github.com/requests/requests/archive/v2.19.1.tar.gz";
    sha256 = "0cd8jyqgs5cal0wrwrd44n3a2mxzy42mljq3qnaszg0mdg63nf58";
  };

  doCheck = false;

  propagatedBuildInputs = [
    /* FIXME */
    python.pkgs.urllib3
    python.pkgs.chardet
  ];

  meta = with stdenv.lib; {
    description = "A Python Slugify application that handles Unicode";
    homepage = https://github.com/requests/requests;
    license = licenses.mit;
  };
}
