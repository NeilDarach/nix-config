{ config, pkgs, lib, inputs, outputs, users, ... }:
let secretspath = builtins.toString inputs.secrets;
in {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    ../server.nix
    ../../home/neil
    ./nginx.nix
    ./nfs.nix
    ./tftpd.nix
    ./transmission.nix
    ./zigbee2mqtt.nix
    ./espresense.nix
    ./appdaemon.nix
    ./gitea.nix
    ./plex.nix
    ./esphome.nix
    ./homeassistant
    ./jellyfin.nix
    ./influxdb.nix
    ./grafana.nix
    ./ups.nix
  ];

  boot.initrd.systemd.emergencyAccess = true;
  sops.age.keyFile = "/keys/key.txt";
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = "${secretspath}/secrets.yaml";

  sops.secrets = {
    "sshd_hostkey_gregor_rsa" = { path = "/etc/ssh/sshd_hostkey_rsa"; };
    "sshd_hostkey_gregor_ed25519" = { path = "/etc/ssh/sshd_hostkey_ed25519"; };
    "user_password_hashed" = { neededForUsers = true; };
    "root_password_hashed" = { neededForUsers = true; };
  };

  sops.secrets."nut/nut_password" = { owner = "nutmon"; };
  registration = {
    etcdHost = "arde.darach.org.uk:2379";
    serviceHost = "gregor.darach.org.uk";
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
    systemPackages = [ pkgs.bluez pkgs.vim ];
    shellAliases.nr =
      "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
  };

  hardware.bluetooth.enable = true;
  services.dbus = {
    implementation = "broker";
    enable = true;
  };
  services.msg_q = {
    enable = true;
    port = 9000;
    openFirewall = true;
  };

}
