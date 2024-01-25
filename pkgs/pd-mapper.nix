{ self', pkgs, lib }:
pkgs.stdenv.mkDerivation rec {
  pname = "pd-mapper";
  version = "107104b";

  src = pkgs.fetchFromGitHub {
    owner = "andersson";
    repo = "pd-mapper";
    rev = "${version}";
    sha256 = "sha256-ypLS/g1FNi2vzIYkIoml2FkMM1Tc8UrRRhWaYbwpwkc=";
  };

  nativeBuildInputs = with self'.packages; [ x13s-firmware qrtr ];

  preBuild = ''
    sed -i 's|/lib/firmware/|${
      self'.packages.x13s-firmware
    }/lib/firmware/|g' pd-mapper.c
    grep "/lib/firmware/" pd-mapper.c
  '';

  makeFlags = [
    "CC=gcc"
    "prefix=$(out)"
  ];

  meta = with lib; {
    description = "pd-mapper";
    homepage = "https://github.com/andersson/pd-mapper";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
