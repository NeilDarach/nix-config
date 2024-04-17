{ config, pkgs, lib, ... }:
let
  color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
  fromGitHub = import ./functions/fromGitHub.nix;
in
{
  imports = [
  ./globalsettings.nix
  ./colorscheme.nix
  ./whichkey.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      which-key-nvim
      (fromGitHub { inherit pkgs; rev="ac7ad3c8e61630d15af1f6266441984f54f54fd2"; ref="main"; user="elihunter173"; repo="dirbuf.nvim"; })
      ];
    };
  }
