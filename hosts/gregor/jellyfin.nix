{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/jellyfin";
    user = "jellyfin";
    group = "jellyfin";
    mode = "u=rwx,g=rx,o=rx";
  }];
  systemd.services.plex = {
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration jellyfin 192.168.4.5 8096 "Jellyfin Media Server"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/jellyfin" ];
    };
    wants = [ "registration.timer" ];
  };

  services.jellyfin = {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
  };
}

