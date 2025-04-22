{
  pkgs,
  linux_pkg,
  ...
}@args:

let
  scriptName = "echo-linux-version";
  script = pkgs.writeShellScriptBin scriptName ''
    cd ${linux_pkg.src.outPath}
    eval $(head -6 Makefile | tail -5 | sed -s "s/ = /=/" | egrep -v 'EXTRAVERSION|NAME')
    echo "$VERSION.$PATCHLEVEL.$SUBLEVEL"
  '';
  scriptRunEnv = with pkgs; [ coreutils-full gnused gnugrep ];

in pkgs.symlinkJoin {
  name = scriptName;
  paths = [ script ] ++ scriptRunEnv;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${scriptName} --prefix PATH : $out/bin";
}
