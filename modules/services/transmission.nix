{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.svc-transmission = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos; [ ];
      options.local.transmission = {
        enable = lib.mkEnableOption "transmission on this host";
      };
      config = lib.mkIf config.local.transmission.enable {
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

        registration.service.transmission = {
          port = 9091;
          description = "Transmission Torrent Client";
        };

        systemd.services.transmission.serviceConfig.BindPaths =
          [ "/Media/Movies" "/Media/TV" ];

        services.transmission = {
          enable = true;
          package = pkgs.transmission_4;
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
            ratio-limit = 3;
            ratio-limit-enabled = true;
            rpc-authentication-required = false;
            rpc-bind-address = "0.0.0.0";
            rpc-host-whitelist-enabled = false;
            rpc-whitelist-enabled = false;
            script-torrent-done-enabled = true;
            script-torrent-done-filename = "${pkgs.transcode}/bin/transcode";
            watch-dir-enable = true;
          };
        };
      };
    };
  };
}
