{ config, pkgs, lib, inputs, outputs, users, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    (import ../server.nix { hostname = "gregor"; })
    ../../home/neil
    ./nginx.nix
    ./nfs.nix
    ./tftpd.nix
    (import ./transmission.nix { inherit pkgs config outputs; })
    (import ./zigbee2mqtt.nix { inherit pkgs config outputs; })
    (import ./homeassistant { inherit pkgs config outputs; })
    (import ./espresense.nix { inherit pkgs config outputs; })
    (import ./appdaemon.nix { inherit pkgs config outputs; })
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
    systemPackages = [ pkgs.bluez ];
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
