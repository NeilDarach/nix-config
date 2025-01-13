{ pkgs, ... }:
let
  src = builtins.readFile ./strongStateDir;
  strongStateDir = (pkgs.writeScriptBin "strongStateDir" src).overrideAttrs
    (p: {
      buildCommand = ''
        ${p.buildCommand}
        patchShebangs $out
      '';
    });
in pkgs.symlinkJoin {
  name = "strongStateDir";
  paths = [ strongStateDir ] ++ (with pkgs; [ gzip openssh gnugrep util-linux zfs ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/strongStateDir --prefix PATH : $out/bin";
}
