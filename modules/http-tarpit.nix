{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.http-tarpit =
      nixosArgs@{ pkgs, config, ... }:

      let
        cfg = config.services.http-tarpit;
      in
      {
        options.services.http-tarpit = {
          enable = lib.mkEnableOption "HTTP tarpit for fail2ban";
          port = lib.mkOption {
            type = lib.types.port;
            default = "8080";
          };
        };
        config = lib.mkIf cfg.enable {
          systemd.services.http-tarpit = {
            description = "HTTP tarpit";
            requires = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig =
              let
                needsPrivileges = cfg.port < 1024;
                capabilities = [ "" ] ++ lib.optionals needsPrivileges [ "CAP_NET_BIND_SERVICE" ];
                rootDirectory = "/run/http-tarpit";
              in
              {
                Restart = "always";

                ExecStart =
                  with cfg;
                  lib.concatStringsSep " " [
                    "${pkgs.http-tarpit}/bin/http-tarpit"
                    "-listen=:${toString port}"
                  ];
                DynamicUser = true;
                RootDirectory = rootDirectory;
                BindReadOnlyPaths = [ builtins.storeDir ];
                InaccessiblePaths = [ "-+${rootDirectory}" ];
                RuntimeDirectory = baseNameOf rootDirectory;
                RuntimeDirectoryMode = "700";
                AmbientCapabilities = capabilities;
                CapabilityBoundingSet = capabilities;
                UMask = "0077";
                LockPersonality = true;
                MemoryDenyWriteExecute = true;
                NoNewPrivileges = true;
                PrivateDevices = true;
                PrivateTmp = true;
                PrivateUsers = !needsPrivileges;
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectHome = true;
                ProtectHostname = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectSystem = "strict";
                ProtectProc = "noaccess";
                ProcSubset = "pid";
                RemoveIPC = true;
                RestrictAddressFamilies = [
                  "AF_INET"
                  "AF_INET6"
                ];
                RestrictNamespaces = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                SystemCallArchitectures = "native";
                SystemCallFilter = [
                  "@system-service"
                  "~@resources"
                  "~@privileged"
                ];
              };
          };
        };
      };
  };
}
