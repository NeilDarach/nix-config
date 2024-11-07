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
        directory = "/var/lib/tftp";
        user = "root";
        group = "root";
        mode = "u=rwx,g=rwx,o=rwx";
      }
      {
        directory = "/var/lib/nfs";
        user = "root";
        group = "root";
        mode = "u=rwx,g=rwx,o=rwx";
      }
    ];

    files = [ "/etc/machine-id" ];
  };
}
