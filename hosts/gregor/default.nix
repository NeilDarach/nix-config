{ config, pkgs, lib, inputs, outputs, users, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    (import ../server.nix { hostname = "gregor"; })
    ../../home/neil
    ./zigbee2mqtt.nix
    ./nginx.nix
  ];

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  environment = {
    systemPackages = [ ];
    shellAliases.nr =
      "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
  };

  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /var/lib/nfs/yellow 192.168.4.89(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  fileSystems."/var/lib/tftp/93fed9e9" = {
    device = "/var/lib/nfs/yellow/boot";
    options = [ "bind" ];
  };

  services.atftpd = {
    enable = true;
    root = "/var/lib/tftp";
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

  networking.firewall.allowedTCPPorts = [ 111 8080 ];
  networking.firewall.allowedUDPPorts = [ 111 69 ];

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
