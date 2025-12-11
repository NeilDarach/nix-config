{ outputs, inputs, ... }: {
  local_packages = final: previous:
    import ../packages {
      pkgs = final;
      inherit outputs;
    };
  disable_gnome = final: previous: {
    networkmanager-l2tp = previous.networkmanager-l2tp.override { withGnome = false; };
    networkmanager-openconnect =
     previous.networkmanager-openconnect.override { withGnome = false; };
    #networkmanager-vpnc =previous.networkmanager-vpnc.override { withGnome = false; };
    networkmanager-iodine =
     previous.networkmanager-iodine.override { withGnome = false; };
    networkmanager-openvpn =
     previous.networkmanager-openvpn.override { withGnome = false; };
    networkmanager-libnma =
     previous.networkmanager-libnma.override { withGnome = false; };
    networkmanager-fortislvpn =
     previous.networkmanager-fortislvpn.override { withGnome = false; };
    networkmanager-sstp =previous.networkmanager-sstp.override { withGnome = false; };
  };

  msg_q = final: previous: { msg_q = inputs.msg_q.packages.${previous.system}.default; };
  polars = final: previous: {
    python3 = previous.python3.override {
      packageOverrides = pf: pp: {
        polars = pp.polars.overrideAttrs (finalAttrs: previousAttrs: {
          env.RUSTFLAGS = "${previousAttrs.env.RUSTFLAGS} -Aunusued_imports";
          env.RUSTC_BOOTSTRAP = 1;
          env.CARGO_BUILD_JOBS = 1;
        });
      };
    };

  };
  plexpass = final: previous:
    let version = "1.42.2.10156-f737b826c";
    in {
      plex = previous.plex.override {
        plexRaw = previous.plexRaw.overrideAttrs (o: {
          src =final.fetchurl {
            inherit version;
            url =
              "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
            sha256 = "sha256-1ieh7qc1UBTorqQTKUQgKzM96EtaKZZ8HYq9ILf+X3M=";
          };
        });
      };
    };
}
