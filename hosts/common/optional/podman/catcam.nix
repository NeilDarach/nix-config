{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  baseDir = "/services/catcam";
  inherit (config.localServices.catcam) pool enable;
  img = pkgs.dockerTools.pullImage {
    # nix-prefetch-docker  --os linux --arch arm64 --image-name linuxserver/homeassistant --image-tag 2024.4.4

    imageName = "ghcr.io/blakeblackshear/frigate";
    imageDigest = "sha256:2906991ccad85035b176941f9dedfd35088ff710c39d45ef1baa9a49f2b16734";
    sha256 = "1wacmn7vxdj9qsc71mz1mx2cj1r2p8anghkz1np46vfmj5a8klrs";
    finalImageName = "ghcr.io/blakeblackshear/frigate";
    finalImageTag = "stable";
  };
in {
  options = {
    localServices.catcam.pool = lib.mkOption {
      default = config.networking.hostName;
      type = lib.types.str;
    };
  };

  config = mkIf enable {
    networking.firewall.allowedTCPPorts = [5000 8554 8555];
    users.groups = {
      catcam = {
        gid = 5000;
      };
    };
    users.users.catcam = {
      uid = 5000;
      group = "catcam";
      extraGroups = ["systemd-journal"];
      createHome = false;
      home = "/services/catcam";
      isNormalUser = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../../../../home/neil/id_ed25519.pub)
      ];
      hashedPassword = "!";
    };
    virtualisation = {
      oci-containers = {
        backend = "podman";
        containers = {
          catcam = {
            imageFile = img;
            image = "ghcr.io/blakeblackshear/frigate:stable";
            environment = {
              FRIGATE_RTSP_PASSWORD = "password";
            };
            volumes = [
              "/etc/localtime:/etc/localtime:ro"
              "${baseDir}/config:/config"
              "${baseDir}/storage:/media/frigate"
            ];
            ports = [
              "5000:5000"
              "8554:8554"
              "8555:8555/tcp"
              "8555:8555/udp"
            ];
            extraOptions = [
              "--network=host"
            ];
            autoStart = true;
          };
        };
      };
    };
    systemd.services.prepare-catcam = {
      description = "Prepare for catcam container";
      enable = true;
      wantedBy = ["podman-catcam.service"];

      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        mkdir -p ${baseDir}
        ${pkgs.zfs}/bin/zfs list ${pool}${baseDir} || ${pkgs.zfs}/bin/zfs create -p -u -o mountpoint=legacy ${pool}${baseDir}
        [[ -f ${baseDir}/mounted.txt ]] || ${pkgs.util-linux}/bin/mount -t zfs ${pool}${baseDir} ${baseDir}
        echo > ${baseDir}/mounted.txt
      '';
    };

    systemd.services.podman-catcam = {
      after = ["prepare-catcam.service"];
    };
  };
}
