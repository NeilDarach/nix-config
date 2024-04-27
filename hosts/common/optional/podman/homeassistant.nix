{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  baseDir = "/services/homeassistant";
  inherit (config.localServices.homeassistant) pool enable;
  tribut =
    pkgs.fetchFromGitHub
    {
      owner = "tribut";
      repo = "homeassistant-docker-venv";
      rev = "52cbfdc494676c91d2575755559dfd38fd5d88cc";
      hash = "sha256-j+TsxbJNQQsNEtwfJfWsZBVB2RRSotGjyizZ0qdSNjA=";
    };
  habase = pkgs.dockerTools.buildImage {
    name = "homeassistant";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "homeassistant/home-assistant";
      imageDigest = "sha256:73b70d36610466a46f1ae3b890bc43f06b48a1ac98b4f28c5d52cf424e476cd5";
      sha256 = "08inhwjanb8cjqxpp0yrzfs79wbkv8q451f2j4dpd1n00mdma0jp";
      finalImageName = "homeassistant/home-assistant";
      finalImageTag = "stable";
    };
    copyToRoot = pkgs.buildEnv {
      name = "rootless";
      paths = [tribut];
      extraPrefix = "/etc/services.d/home-assistant";
    };
    config = {
      Cmd = ["/init"];
      WorkingDir = "/config";
      Volumes = {
        "/config" = {};
        "/run/dbus" = {};
      };
    };
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
      extraGroups = ["systemd-journal"];
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
            image = "homeassistant:latest";
            imageFile = habase;
            environment = {
              "TZ" = "Europe/London";
              "PUID" = "8123";
              "PGID" = "8123";
            };
            volumes = [
              "${baseDir}:/config"
              "/run/dbus:/run/dbus:ro"
            ];
            extraOptions = [
              "--name=homeassistant"
              "--network=host"
              "--privileged"
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

    systemd.services.podman-homeassistant.after = ["prepare-homeassistant.service"];
  };
}
