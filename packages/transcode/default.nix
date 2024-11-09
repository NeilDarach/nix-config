{ pkgs, ... }:
let
  transcode_src = builtins.readFile ./transcode;
  transcode_bare = (pkgs.writeScriptBin "transcode" transcode_src).overrideAttrs
    (p: {
      buildCommand = ''
        ${p.buildCommand}
         patchShebangs $out'';
    });
  cliHandbrake = pkgs.handbrake.override { useGtk = false; };

in pkgs.symlinkJoin {
  name = "transcode";
  paths = [ transcode_bare ] ++ (with pkgs; [
    jq
    coreutils
    curl
    tvnamer
    transmission
    cliHandbrake
    procps
  ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/transcode --prefix PATH : $out/bin";
}
