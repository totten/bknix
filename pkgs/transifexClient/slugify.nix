{ buildPythonPackage, fetchurl, stdenv, unidecode }:
buildPythonPackage rec {

  name = "python-slugify";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/00/ad/c778a6df614b6217c30fe80045b365bfa08b5dd3cb02e8b37a6d25126781/python-slugify-1.2.6.tar.gz";
    sha256 = "0i9j36w7jb4znaf5rw0dqxnzd66bbzgxrgbn65bjdnwn17rxl8vp";
  };

  doCheck = false;

  propagatedBuildInputs = [ unidecode ];

  meta = with stdenv.lib; {
    description = "A Python Slugify application that handles Unicode";
    homepage = https://github.com/un33k/python-slugify;
    license = licenses.mit;
  };
}
