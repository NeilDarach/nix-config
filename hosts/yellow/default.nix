{ config, pkgs, lib, inputs, outputs, users, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./impermanence.nix
    (import ../server.nix { hostname = "yellow"; })
    ../../home/neil
  ];

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  sops.secrets = {
    "sshd_hostkey_yellow_rsa" = { };
    "sshd_hostkey_yellow_ed25519" = { };
    "user_password_hashed" = { neededForUsers = true; };
    "root_password_hashed" = { neededForUsers = true; };
  };

  networking = {
    hostName = "yellow";
    hostId = "95849593";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  console.enable = true;
}
