{ config, pkgs, lib, inputs, outputs, users, ... }: {
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
    "zigbee2mqtt_secrets" = { mode = "0400"; path = "/var/lib/zigbee2mqtt/secret.yaml"; owner = "zigbee2mqtt"; group = "zigbee2mqtt"; };
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
    systemPackages = [ ];
    shellAliases.nr =
      "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
  };

  services.msg_q = {
    enable = true;
    port = 9000;
    openFirewall = true;
  };

  services.plex = {
    enable = true;
    dataDir = "/var/lib/plex";
    openFirewall = true;
    user = "plex";
    group = "plex";
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = true;
      frontend = {
        port = 8080;
        host = "0.0.0.0";
      };
      mqtt = {
        base_topic = "zigbee2mqtt2";
        server = "mqtt://mqtt.darach.org.uk";
        user = "!secret.yaml mqtt_user";
        password = "!secret.yaml mqtt_password";
      };
      serial = {
        port = "tcp://uzg-01.darach.org.uk:6638";
        baudrate = 115200;
      };
      advanced = {
        pan_id = 64711;
        network_key = "!secret.yaml network_key";
      };
    };
    dataDir = "/var/lib/zigbee2mqtt";
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission;
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
