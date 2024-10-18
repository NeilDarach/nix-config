{ user, ... }: {
  home-manager.users.${user} = { inputs, outputs, lib, config, pkgs, ... }: {
    imports = [ ];
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    programs.home-manager.enable = true;
    programs.fish.enable = true;
    xdg.enable = true;
    programs.git = {
      enable = true;
      ignores = [ "*~" "*.swp" ];
      userEmail = "neil.darach@gmail.com";
      userName = "Neil Darach";
    };
    systemd.user.startServices = "sd-switch";
    home.sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
      EDITOR = "vim";
    };
    home.packages = with pkgs; [
      ripgrep
      fd
      curl
      less
      jq
      coreutils
      perl
      python3
      ruby
      gcc
      inputs.nixNvim.packages.${pkgs.system}.nvim
    ];
    home.username = "${user}";
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "24.05";
  };
}
