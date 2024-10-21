{ config, pkgs, lib, inputs, outputs, user, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    ../server.nix
    ../../home/neil
  ];
  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  sops.secrets = {
    "sshd_hostkey_gregor_rsa" = { };
    "sshd_hostkey_gregor_ed25519" = { };
    "user_password_hashed" = { neededForUsers = true; };
    "root_password_hashed" = { neededForUsers = true; };
  };

  networking = {
    hostName = "gregor";
    hostId = "42231481";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  fileSystems."/home" = {
    device = "silent/home";
    fsType = "zfs";
    neededForBoot = true;
  };

  environment = {
        systemPackages = [
        ];
    shellAliases.nr =
      "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
  };

    services.msg_q = {
        enable = true;
        port = 9000;
    };

  services.plex = {
    enable = true;
    dataDir = "/var/lib/plex";
    openFirewall = true;
    user = "plex";
    group = "plex";
  };

    services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        user = "transmission";
        group = "transmission";
        openFirewall = true;
        openPeerPorts = true;
        openRPCPort = true;
        downloadDirPermissions = "770";
        home = "/var/lib/transmission";
        settings = {
            download-queue-enabled = true;
            download-queue-size = 5;
            encryption = 1;
            rpc-authentication-required = false;
            rpc-bind-address = "0.0.0.0";
            rpc-host-whitelist-enabled = false;
            rpc-whitelist-enabled = false;
        };
    };
}
