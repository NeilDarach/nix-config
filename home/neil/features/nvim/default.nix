{ config, pkgs, lib, ... }:
let
  color = pkgs.writeText "color.vim" (import ./theme.nix config.colorscheme);
  fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
      };
    };
in
{
  imports = [
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
      (fromGitHub "ac7ad3c8e61630d15af1f6266441984f54f54fd2" "main" "elihunter173/dirbuf.nvim")
      ];
    };
  }
