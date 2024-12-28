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
  tvnamer_cfg = ./tvnamer.json;

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
    findutils
  ]);
  buildInputs = [ pkgs.makeWrapper ];
  postBuild =
    "wrapProgram $out/bin/transcode --set PATH $out/bin --set TVNAMERCFG ${tvnamer_cfg}";
}
