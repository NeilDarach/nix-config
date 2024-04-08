{ config, pkgs, ... }:
let
  color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
in
{
  imports = [
  ];
  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;
    };
  }
