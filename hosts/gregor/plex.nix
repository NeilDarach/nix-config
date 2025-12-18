{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/plex";
    user = "plex";
    group = "plex";
    mode = "u=rwx,g=rx,o=rx";
  }];
  registration.plex = {
    description = "Plex Media Server";
    port = 32400;
  };

  services.plex = {
    enable = true;
    dataDir = "/var/lib/plex";
    openFirewall = true;
    user = "plex";
    group = "plex";
  };
}

