{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.common =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ ];
        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = with pkgs; [
          bat
          curl
          dig
          dnsutils
          ethtool
          file
          git
          jq
          lsof
          mc
          nixNvim
          nvd
          psmisc
          python3
          ripgrep
          sysstat
          unzip
          usbutils
          wget
          zfs
        ];
        home-manager = {
          extraSpecialArgs = { inherit inputs; };
          useGlobalPkgs = true;
          useUserPackages = true;
        };
        programs = {
          fish.enable = true;
          git.enable = true;
        };
        documentation.man.generateCaches = false;
      };
    homeManager.common =
      nixosArgs@{ pkgs, config, ... }:
      {
        config = {
          programs.home-manager.enable = lib.mkDefault true;
          xdg.enable = lib.mkDefault true;
          systemd.user.startServices = lib.mkIf config.programs.home-manager.enable "sd-switch";
        };
      };
  };
}
