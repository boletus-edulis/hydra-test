{ pkgs, lib }:
pkgs.stdenv.mkDerivation rec {
  pname = "qrtr";
  version = "d0d471c";

  src = pkgs.fetchFromGitHub {
    owner = "andersson";
    repo = "qrtr";
    rev = "${version}";
    sha256 = "sha256-KF0gCBRw3BDJdK1s+dYhHkokVTHwRFO58ho0IwHPehc=";
  };

  makeFlags = [
    "CC=gcc"
    "prefix=$(out)"
  ];

  meta = with lib; {
    description = "qrtr";
    homepage = "https://github.com/andersson/qrtr";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
