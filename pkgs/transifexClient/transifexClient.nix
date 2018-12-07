{ lib, python, fetchFromGitHub, slugify, requests }:
with python.pkgs;
buildPythonApplication rec {
  pname = "transifex-client";
  version = "0.13.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "00igk35nyzqp1slj7lbhiv4lc42k87ix43ipx2zcrsjf6xxv6l7v";
  };

  doCheck = false;

  propagatedBuildInputs = [ urllib3 slugify requests ];

  meta = {
    homepage = https://github.com/transifex/transifex-client;
    description = "Transifex CLI Client";
    license = lib.licenses.bsd2;
  };
}
