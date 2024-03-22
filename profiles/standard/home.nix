{ config, pkgs, userSettings, ... }: {
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  programs.home-manager.enable = true;

  imports = [ ../../user/shell/sh.nix
              ../../user/app/git.nix
	      ];

  home.stateVersion = "22.11"; # Please read the comment before changing

  home.packages = with pkgs; [ git neovim tmux ];

  home.sessionVariables = {
    EDITOR = userSettings.editor;
    };
  }
