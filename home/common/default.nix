{ inputs, outputs, lib, pkgs, config, ... }: {
  imports = [ ./git ./direnv ./fish ];
  programs.home-manager.enable = lib.mkDefault true;
  xdg.enable = lib.mkDefault true;
  systemd.user.startServices = "sd-switch";
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
  home.packages = with pkgs; [ curl less jq coreutils ];
  home.stateVersion = "24.05";
}
