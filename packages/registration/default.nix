{ pkgs, ... }:
let
  src = builtins.readFile ./registration;
  registration = (pkgs.writeScriptBin "registration" src).overrideAttrs
    (p: {
      buildCommand = ''
        ${p.buildCommand}
         patchShebangs $out'';
    });

in pkgs.symlinkJoin {
  name = "registration";
  paths = [ registration ] ++ (with pkgs; [
    etcd
    findutils
  ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/registration --prefix PATH : $out/bin";
}
