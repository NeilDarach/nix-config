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
          inputs.sops-nix.nixosModules.sops
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
        sops = {
          secrets = {
            "sshd_hostkey_${config.networking.hostName}_rsa" = {
              path = "/etc/ssh/ssh_host_rsa_key";
            };
            "sshd_hostkey_${config.networking.hostName}_ed25519" = {
              path = "/etc/ssh/ssh_host_ed25519_key";
            };
          };
        };
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        networking.firewall.enable = true;
        networking.networkmanager.enable = true;
        time.timeZone = "Europe/London";

        security.sudo.wheelNeedsPassword = false;
        nix.settings.trusted-users = [
          "root"
          "@wheel"
        ];
        services.openssh.enable = true;
        i18n = {
          defaultLocale = "en_GB.UTF-8";
        };
        environment.etc = {
          "systemd/journald.conf.d/99-storage.conf".text = ''
            [Journal]
            Storage=volatile
          '';
        };
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
