{
  lib,
  pkgs,
  stdenv,
  makeWrapper,
  coreutils,
} :
with lib;
stdenv.mkDerivation {
  name = "bootstrap";
  version = "1.0";
  src = ./bootstrap.sh;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm 0755 $src $out/bin/bootstrap
    wrapProgram $out/bin/bootstrap --prefix PATH \
      "${ makeBinPath [ coreutils ] }"
      '';
  meta = {
    description = "Generate commands to set up a new machine for nixos";
    platforms = platforms.all;
    mainProgram = "bootstrap";
    };
  }
