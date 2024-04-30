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

  ha-overlay = pkgs.stdenv.mkDerivation {
    name = "ha-overlay";
    version = "1.0";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/pkgs
      for src in $srcs ; do
        cp ''$src $out/pkgs/''${src#*-}
      done
      mkdir -p $out/etc/s6-overlay/s6-rc.d/{setBluetoothOneshot,svc-homeassistant/dependencies.d,user/contents.d}
      echo "oneshot" > $out/etc/s6-overlay/s6-rc.d/setBluetoothOneshot/type
      echo "/usr/local/bin/setBluetoothCapabilities.sh" > $out/etc/s6-overlay/s6-rc.d/setBluetoothOneshot/up
      touch $out/etc/s6-overlay/s6-rc.d/user/contents.d/setBluetoothOneshot
      touch $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/dependencies.d/setBluetoothOneshot
      echo "#!/usr/bin/with-contenv bash" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "# shellcheck shell=bash" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "setcap 'cap_net_bind_service,cap_net_raw,cap_net_admin+eip' /usr/local/bin/python3.12" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo 'if [[ -z "''${DISABLE_JEMALLOC+x}" ]]; then' >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "  export LD_PRELOAD=\"/usr/local/lib/libjemalloc.so.2\"" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "  export MALLOC_CONF=\"background_thread:true,metadata_thp:auto,dirty_decay_ms:20000,muzzy_decay_ms:20000\"" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "fi" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "exec \\" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "    s6-notifyoncheck -d -n 60 -w 5000 -c \"nc -z localhost 8123\" \\" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      echo "    s6-setuidgid abc python3 -m homeassistant -c /config" >> $out/etc/s6-overlay/s6-rc.d/svc-homeassistant/run
      mkdir -p $out/usr/local/bin
      echo "#!/bin/bash" >> $out/usr/local/bin/setBluetoothCapabilities.sh
      echo "pip install --no-index --find-links file:///pkgs aioblescan janus" >> $out/usr/local/bin/setBluetoothCapabilities.sh
      chmod +x $out/usr/local/bin/setBluetoothCapabilities.sh
    '';
    srcs = [
      (pkgs.fetchurl
        {
          url = "https://files.pythonhosted.org/packages/2a/4c/b8e1a16c5baf299b540dd4a21c1b804651d9d7a1b2f459557d94f16c2baa/aioblescan-0.2.14-py3-none-any.whl";
          hash = "sha256-HjiXe8IH9lisHiHbIaWOlBup2mw2KoifQRPYDhz4b70=";
        })
      (pkgs.fetchurl
        {
          url = "https://files.pythonhosted.org/packages/c1/84/7bfe436fa6a4943eecb17c2cca9c84215299684575376d664ea6bf294439/janus-1.0.0-py3-none-any.whl";
          hash = "sha256-JZbqVIJxHB7j7y32wpCq83ChPFWgB4Juj3wy1pbR0Ao=";
        })
    ];
  };

  ha = pkgs.dockerTools.buildImage {
    name = "local/homeassistant";
    tag = "local";
    fromImage = img;
    copyToRoot = pkgs.buildEnv {
      name = "homeassistant-pips";
      paths = [ha-overlay];
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
