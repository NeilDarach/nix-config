{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-espresense =
      nixosArgs@{
        pkgs,
        config,
        lib,
        ...
      }:
      let
        # Get the tags with
        #     nix run nixpkgs#nix-prefetch-docker -- nix-prefetch-docker --image-name espresense/espresense-companion --image-tag 2.0.4-b117  --arch arm64 --os linux
        tags =
          {
            "aarch64-linux" = {
              sha256 = "sha256-eJtwEaYpK9NrYLJb7u+yN5xkhBEUva7mWJxG8uWmv/4=";
              os = "linux";
              arch = "arm64";
              imageDigest = "sha256:444ffa6ef0f6dfce6f17a4b3b5bb148624eb53d05b93078c6e6916b378822c29";
            };

            "x86_64-linux" = {
              sha256 = "sha256-/g3vQ6avgMQk1mIdU8Ck3U72KzSZ0DKAk/u5eP0OcCs=";
              os = "linux";
              arch = "amd64";
              imageDigest = "sha256:2dad854a3dc4788ee8f213191b4e020de24f5fc375a1803ebbd8ade18995fad1";
            };
          }
          ."${pkgs.stdenv.hostPlatform.system}";
        base = pkgs.dockerTools.pullImage (
          tags
          // {
            imageName = "espresense/espresense-companion";
            finalImageTag = "2.0.4-b117";
          }
        );
      in
      {
        imports = with inputs.self.modules.nixos; [ ];
        options.local.espresense = {
          enable = lib.mkEnableOption "espresense on this host";
        };
        config = lib.mkIf config.local.espresense.enable {

          sops.secrets.mqtt-user = {
            restartUnits = [ "espresense.service" ];
          };
          sops.secrets.mqtt-password = {
            restartUnits = [ "espresense.service" ];
          };

          networking.firewall.allowedTCPPorts = [
            8267
            8268
          ];

          virtualisation.oci-containers = {
            containers.espresense = {
              serviceName = "espresense";
              volumes = [ "/strongStateDir/espresense:/config/espresense" ];
              environment.TZ = "Europe/London";
              image = "espresense/espresense-companion:2.0.4-b117";
              imageFile = base;
              autoStart = true;
              ports = [
                "8267:8267"
                "8268:8268"
              ];
              extraOptions = [ ];
            };
          };

          strongStateDir.service.espresense = {
            enable = true;
            localUser = "root";
            localGroup = "root";
          };

          registration.service.espresense = {
            port = 8267;
            description = "Espresense companion";
          };

          systemd.services.espresense = {
            enable = true;
            serviceConfig = {
              ExecStartPre = "${pkgs.coreutils}/bin/chmod go-rw /strongStateDir/espresense/config.yaml";
            };
          };
        };
      };
  };
}
