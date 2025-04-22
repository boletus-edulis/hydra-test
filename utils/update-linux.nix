{
  pkgs,
  linux_pkg,
  ...
}@args:

let
  cuf = pkgs.coreutils-full;
in
pkgs.writeShellScriptBin "echo-linux-version" ''
  HEAD=${pkgs.coreutils-full}/bin/head
  TAIL=${pkgs.coreutils-full}/bin/tail
  SED=${pkgs.gnused}/bin/sed
  EGREP=${pkgs.gnugrep}/bin/egrep

  cd ${linux_pkg.src.outPath}
  eval $($HEAD -6 Makefile | $TAIL -5 | $SED -s "s/ = /=/" | $EGREP -v 'EXTRAVERSION|NAME')

  echo "$VERSION.$PATCHLEVEL.$SUBLEVEL"
''
