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
      script = (pkgs.writeScriptBin "zfs-backup" (builtins.readFile ./zfs-backup)).overrideAttrs (p: {
        buildCommand = ''
          ${p.buildCommand}
          patchShebangs $out
        '';
      });
      zfs-backup = pkgs.symlinkJoin {
        name = "zfs-backup";
        paths = [
          script
        ]
        ++ (with pkgs; [
          gzip
          coreutils
          openssh
          zfs
        ]);
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/zfs-backup --prefix PATH : $out/bin";

      };
    in
    {
      packages = { inherit zfs-backup; };
    };
}
