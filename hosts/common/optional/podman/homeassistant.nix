{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  baseDir = "/services/homeassistant";
  inherit (config.localServices.homeassistant) pool enable;
  img = pkgs.dockerTools.pullImage {
    # nix-prefetch-docker  --os linux --arch arm64 --image-name linuxserver/homeassistant --image-tag 2024.4.4

    imageName = "linuxserver/homeassistant";
    imageDigest = "sha256:ac7117fced74c60b5449301c3eb419a9d00fb776da6b60efd6a91a182b561356";
    sha256 = "0kmf2fqwll8mgmx3i4lkjd28qq50i0mwszr0ivqwdmfdpw2i8wq7";
    finalImageName = "linuxserver/homeassistant";
    finalImageTag = "2024.4.4";
  };

  ha = pkgs.dockerTools.buildImage {
    name = "local/homeassistant";
    tag = "local";
    fromImage = img;
    copyToRoot = pkgs.buildEnv {
      name = "homeassistant-pips";
      paths = [./homeassistant-pip];
    };
    #    runAsRoot = ''
    #!/bin/bash
    #      export PATH=/lsiopy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

    #      mkdir -p /etc/s6-overlay/s6-rc.d/setBluetoothOneshot
    #      echo "oneshot" > /etc/s6-overlay/s6-rc.d/setBluetoothOneshot/type
    #      echo "foreground { echo 'Setting bluetooth capabilities' } " > /etc/s6-overlay/s6-rc.d/setBluetoothOneshot/up
    #      echo "/homeassistant-pip/setBluetoothCapabilities.sh" >> /etc/s6-overlay/s6-rc.d/setBluetoothOneshot/up
    #      touch /etc/s6-overlay/s6-rc.d/user/contents.d/setBluetoothOneshot
    #    '';
    config = {
      Cmd = ["/init"];
      WorkingDir = "/config";
    };
    diskSize = 5120;
    buildVMMemorySize = 1024;
  };
in {
  options = {
    localServices.homeassistant.pool = lib.mkOption {
      default = config.networking.hostName;
      type = lib.types.str;
    };
  };

  config = mkIf enable {
    networking.firewall.allowedTCPPorts = [8123];
    users.groups = {
      homeassistant = {
        gid = 8123;
      };
    };
    users.users.homeassistant = {
      uid = 8123;
      group = "homeassistant";
      extraGroups = ["systemd-journal" "bluetooth"];
      createHome = false;
      home = "/services/homeassistant";
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
          homeassistant = {
            image = "local/homeassistant:local";
            imageFile = ha;
            environment = {
              "TZ" = "Europe/London";
              "PUID" = "8123";
              "PGID" = "8123";
            };
            volumes = [
              "${baseDir}:/config"
              "/var/run/dbus:/var/run/dbus:ro"
              "/dev/rfkill:/dev/rfkill:rw"
            ];
            extraOptions = [
              "--name=homeassistant"
              #"--privileged"
              "--network=host"
              "--cap-add=NET_ADMIN"
              "--cap-add=NET_RAW"
            ];
            autoStart = true;
          };
        };
      };
    };
    systemd.services.prepare-homeassistant = {
      description = "Prepare for home assistant container";
      enable = true;
      wantedBy = ["podman-homeassistant.service"];

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

    systemd.services.podman-homeassistant = {
      after = ["prepare-homeassistant.service"];
    };
  };
}
