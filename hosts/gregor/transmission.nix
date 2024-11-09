{ pkgs, config }: {
  sops.secrets."plex_token" = { };
  sops.templates."plex_token" = {
    content = ''
      header = "X-Plex-Token: ${config.sops.placeholder.plex_token}"
    '';
    path = "/var/lib/transmission/plex_token";
    mode = "0400";
    owner = "transmission";
    group = "transmission";
  };
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/transmission";
    user = "transmission";
    group = "transmission";
    mode = "u=rwx,g=rx,o=rx";
  }];
  services.transmission = {
    enable = true;
    package = pkgs.transmission;
    user = "transmission";
    group = "transmission";
    openFirewall = true;
    openPeerPorts = true;
    openRPCPort = true;
    downloadDirPermissions = "770";
    home = "/var/lib/transmission";
    settings = {
      download-queue-enabled = true;
      download-queue-size = 5;
      encryption = 1;
      rpc-authentication-required = false;
      rpc-bind-address = "0.0.0.0";
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
      script-torrent-done-enabled = true;
      script-torrent-done-filename = "${pkgs.local_transcode}/bin/transcode";
    };
  };
}
