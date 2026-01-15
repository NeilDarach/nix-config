{
  config,
  nixpkgs,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  perSystem =
    { inputs', pkgs, ... }:
    let
      script = (pkgs.writeScriptBin "registration" (builtins.readFile ./registration)).overrideAttrs (p: {
        buildCommand = ''
          ${p.buildCommand}
          patchShebangs $out
        '';
      });
      registration = pkgs.symlinkJoin {
        name = "registration";
        paths = [
          script
        ]
        ++ (with pkgs; [
          etcd
          findutils
        ]);
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/registration --prefix PATH : $out/bin";

      };
    in
    {
      packages = { inherit registration; };
    };
}
