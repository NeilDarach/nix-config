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
        imports = with inputs.self.modules.nixos; [
          common-zfs
          distributedBuilds
          ssh
          git
          strongStateDir
          registration
        ];
        nixpkgs.config.allowUnfree = true;
        registration.etcdHost = "arde.darach.org.uk:2379";
        environment.systemPackages = with pkgs; [
          bat
          curl
          dig
          dnsutils
          ethtool
          file
          git
          gnutar
          iputils
          jq
          lsof
          mc
          mtr
          netcat
          nixNvim
          nvd
          openssl
          psmisc
          python3
          ripgrep
          sysstat
          tree
          unzip
          usbutils
          wget
        ];
        home-manager = {
          extraSpecialArgs = { inherit inputs; };
          useGlobalPkgs = true;
          useUserPackages = true;
        };
        programs = {
          fish.enable = true;
          git.enable = true;
          htop.enable = true;
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
