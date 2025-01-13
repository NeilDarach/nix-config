{ pkgs, ... }:
let
  src = builtins.readFile ./zfs-backup;
  zfs-backup = (pkgs.writeScriptBin "zfs-backup" src).overrideAttrs
    (p: {
      buildCommand = ''
        ${p.buildCommand}
        patchShebangs $out
      '';
    });
in pkgs.symlinkJoin {
  name = "zfs-backup";
  paths = [ zfs-backup ] ++ (with pkgs; [ gzip coreutils openssh zfs ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/zfs-backup --prefix PATH : $out/bin";
}
