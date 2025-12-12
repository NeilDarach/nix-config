{ users, ... }:
let user = users.neil;
in {
  home-manager.users.${user.userId} =
    { inputs, outputs, lib, config, pkgs, ... }: {
      imports = [ ../common ];
      programs.fish.enable = true;
      programs.git.enable = true;
      programs.direnv.enable = true;

      gitcfg.name = user.name;
      gitcfg.email = user.email;

      home.sessionVariables = {
        PAGER = "less";
        CLICOLOR = 1;
        EDITOR = "vim";
      };
      home.packages = with pkgs; [
        lsof
        bat
        ripgrep
        direnv
        fd
        perl
        python3
        ruby
        gcc
        inputs.nixNvim.packages.${pkgs.stdenv.hostPlatform.system}.nvim
      ];
      home.username = "${user.userId}";
      home.homeDirectory = "/home/${user.userId}";
    };
}
