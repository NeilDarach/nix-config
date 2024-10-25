{
  system.activationScripts.createPersist = "mkdir -p /persist";
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      {
        directory = "/var/lib/plex";
        user = "plex";
        group = "plex";
        mode = "u=rwx,g=rx,o=rx";
      }
      {
        directory = "/var/lib/transmission";
        user = "transmission";
        group = "transmission";
        mode = "u=rwx,g=rx,o=rx";
      }
      {
        directory = "/var/lib/zigbee2mqtt";
        user = "zigbee2mqtt";
        group = "zigbee2mqtt";
        mode = "u=rwx,g=rx,o=rx";
      }
    ];

    files = [ "/etc/machine-id" ];
  };
}
