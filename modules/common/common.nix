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
      let
        services = lib.attrValues (
          lib.filterAttrs (n: v: lib.hasPrefix "svc-" n) inputs.self.modules.nixos
        );
      in
      {
        imports =
          with inputs.self.modules.nixos;
          [
            common-zfs
            distributedBuilds
            ssh
            fail2ban
            git
            strongStateDir
            registration
            inputs.sops-nix.nixosModules.sops
          ]
          ++ services;
        environment.etc = {
          "systemd/journald.conf.d/99-storage.conf".text = ''
            [Journal]
            Storage=volatile
          '';
        }
        // (lib.mapAttrs' (name: value: {
          name = "nix/path/${name}";
          value.source = value.flake;
        }) config.nix.registry);
        nixpkgs.config.allowUnfree = true;
        nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
          (lib.filterAttrs (_: lib.isType "flake")) inputs
        );
        nix.nixPath = [ "/etc/nix/path" ];
        registration.etcdHost = "etcd.darach.org.uk:2379";
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
          xxd
        ];
        sops = {
          secrets = {
            "host_keys/${config.networking.hostName}/ed25519/private" = {
              path = "/etc/ssh/ssh_host_ed25519_key";
            };
          };
        };
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        networking.firewall.enable = true;
        networking.enableIPv6 = false;
        networking.networkmanager.enable = true;
        networking.hostId = lib.mkDefault (
          builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName)
        );
        time.timeZone = "Europe/London";

        security.sudo = {
          wheelNeedsPassword = false;
          extraConfig = ''
            Defaults lecture = never
          '';
        };
        nix.settings.trusted-users = [
          "root"
          "@wheel"
        ];
        services.openssh.enable = true;
        i18n = {
          defaultLocale = "en_GB.UTF-8";
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
