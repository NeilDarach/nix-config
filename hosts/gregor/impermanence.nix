{
  system.activationScripts.createPersist = "mkdir -p /persist";
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager"
      "/var/lib/bluetooth"
      "/var/lib/plex"
      "/var/lib/nixos"
      "/var/lib/transmission"
    ];

    files = [ "/etc/machine-id" ];
  };
}
