{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  home.username = "root";
  home.homeDirectory = "/root";

  home.packages = with pkgs; [ git neovim tmux ];

  home.sessionVariables = {
    EDITOR = "nvim";
    };

  programs.git.enable = true;
  programs.git.userName = "Neil Darach";
  programs.git.userEmail = "neil.darach@gmail.com";
  programs.git.extraConfig = {
    init.defaultBranch = "master";
    safe.directory = "/root/.dotfiles";
    };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      };
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
