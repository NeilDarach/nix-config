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
      script = (pkgs.writeScriptBin "transcode" (builtins.readFile ./transcode)).overrideAttrs (p: {
        buildCommand = ''
          ${p.buildCommand}
          patchShebangs $out
        '';
      });
      cliHandbrake = pkgs.handbrake.override { useGtk = false; };
      tvnamer_cfg = ./tvnamer.json;

      transcode = pkgs.symlinkJoin {
        name = "transcode";
        paths = [
          script
        ]
        ++ (with pkgs; [
          jq
          coreutils
          curl
          tvnamer
          transmission_4
          cliHandbrake
          procps
          findutils
        ]);
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/transcode --set PATH $out/bin --set TVNAMERCFG ${tvnamer_cfg}";
      };
    in
    {
      packages = { inherit transcode; };
    };
}
