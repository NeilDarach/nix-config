{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
  thisConfig = config.flake.nixosConfigurations.rpi4-sd.config;
in
{
  configurations.nixos.rpi4-sd.module =
    args@{ pkgs, lib, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
        nixos.common-zfs
        nixos.hardware-rpi4
      ];
      #local.useZfs = true;


      boot.tmp.useTmpfs = true;
      networking = {
        hostName = "nixos";
        useDHCP = lib.mkForce true;
        hostId = "d9165afe";
      };
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      time.timeZone = "Europe/London";

      environment.systemPackages = with pkgs; [
        git
        mc
        psmisc
        curl
        wget
        dig
        file
        nvd
        ethtool
        sysstat
        neovim
        dnsutils
        jq
        unzip
        usbutils
        lsof
      ];

      security.sudo.wheelNeedsPassword = false;
      nix.settings.trusted-users = [
        "root"
        "@wheel"
      ];
      users.users.nix = {
        isNormalUser = true;
        description = "nix";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        password = "nix";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
        ];
      };
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
      system.stateVersion = lib.mkDefault "25.11";

    };
}
