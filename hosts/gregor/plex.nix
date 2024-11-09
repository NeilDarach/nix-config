{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/plex";
    user = "plex";
    group = "plex";
    mode = "u=rwx,g=rx,o=rx";
  }];
  systemd.services.plex = {
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration plex 192.168.4.5 32400 "Plex Media Server"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/plex" ];
    };
    wants = [ "registration.timer" ];
  };

  services.plex = {
    enable = true;
    dataDir = "/var/lib/plex";
    openFirewall = true;
    user = "plex";
    group = "plex";
  };
}

