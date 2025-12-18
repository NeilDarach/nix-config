{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/jellyfin";
    user = "jellyfin";
    group = "jellyfin";
    mode = "u=rwx,g=rx,o=rx";
  }];
  registration.jellyfin = {
    port = 8096;
    description = "Jellyfin Media Server";
  };

  services.jellyfin = {
    enable = true;
    dataDir = "/var/lib/jellyfin";
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
  };
}

