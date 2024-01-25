{ pkgs, lib }:
pkgs.stdenv.mkDerivation {
  pname = "x13s-firmware";
  version = "9999";

  src = pkgs.fetchFromGitHub {
    owner = "ironrobin";
    repo = "x13s-alarm";
    rev = "2dcb4c8";
    sha256 = "sha256-SbqXeU2pjPb4tpDU4/UqBZ8Ev+J6P9qCO5g6no5WFwM=";
  };

  sourceRoot = "./source";
  dontBuild = true;
  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  nativeBuildInputs = [ pkgs.linux-firmware ];

  installPhase = ''
    runHook preInstall

    cp -vaL "${pkgs.linux-firmware}/" "$out/"
    chmod -R +w "$out/"

    mkdir -p "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"
    cp -fv "x13s-firmware/qcvss8280.mbn" \
       "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"

    mkdir -p "$out/lib/firmware/qca"
    cp -fv "x13s-firmware/hpnv21.b8c" "$out/lib/firmware/qca"
    cp -fv "x13s-firmware/a690_gmu.bin" "$out/lib/firmware/qcom"
    # cp -fv "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/audioreach-tplg.bin" \
    #    "$out/lib/firmware/qcom/sc8280xp/SC8280XP-LENOVO-X13S-tplg.bin"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for Lenovo Thinkpad X13s";
    homepage = "https://github.com/ironrobin/x13s-alarm";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
