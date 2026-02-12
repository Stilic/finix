{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "gnu-getopt";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "sabotage-linux";
    repo = "gnu-getopt";
    rev = "v0.0.1";
    sha256 = "sha256-2PKVONr3SG4GW4zx2UIFi1oBrquXQ4ExLSoDWksI4Lw=";
  };

  buildPhase = ''
      make
    '';

    installPhase = ''
        make prefix= DESTDIR=$out install
      '';

  meta = {
    homepage = "https://github.com/sabotage-linux/gnu-getopt";
    description = "getopt[_long] implementation with GNU semantics";
    platforms = lib.platforms.linux;
    license = lib.licenses.isc;
  };
}
