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
  systemd.user.startServices = "sd-switch";
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.05";
    };
}
