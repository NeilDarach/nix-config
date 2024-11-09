{ config, pkgs, lib, inputs, outputs, users, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    (import ../server.nix { hostname = "gregor"; })
    ../../home/neil
    (import ./transmission.nix { inherit pkgs config outputs; })
    (import ./plex.nix { inherit pkgs config outputs; })
        outputs.nixosModules.registration
  ];

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  services.registration.enable = true;
  sops.secrets = {
    "sshd_hostkey_gregor_rsa" = { };
    "sshd_hostkey_gregor_ed25519" = { };
    "user_password_hashed" = { neededForUsers = true; };
    "root_password_hashed" = { neededForUsers = true; };
    "zigbee2mqtt_secrets" = {
      mode = "0400";
      path = "/var/lib/zigbee2mqtt/secret.yaml";
      owner = "zigbee2mqtt";
      group = "zigbee2mqtt";
    };
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

  fileSystems."/Media" = {
    device = "linstore/media";
    fsType = "zfs";
    neededForBoot = false;
  };

  environment = {
    systemPackages = [ ];
    shellAliases.nr =
      "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
  };

  services.msg_q = {
    enable = true;
    port = 9000;
    openFirewall = true;
  };
}
