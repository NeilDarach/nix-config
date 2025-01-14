{ outputs, inputs, ... }: {
  local_packages = f: p:
    import ../packages {
      pkgs = f;
      inherit outputs;
    };
  disable_gnome = f: p: {
    networkmanager-l2tp = p.networkmanager-l2tp.override { withGnome = false; };
    networkmanager-openconnect =
      p.networkmanager-openconnect.override { withGnome = false; };
    #networkmanager-vpnc = p.networkmanager-vpnc.override { withGnome = false; };
    networkmanager-iodine =
      p.networkmanager-iodine.override { withGnome = false; };
    networkmanager-openvpn =
      p.networkmanager-openvpn.override { withGnome = false; };
    networkmanager-libnma =
      p.networkmanager-libnma.override { withGnome = false; };
    networkmanager-fortislvpn =
      p.networkmanager-fortislvpn.override { withGnome = false; };
    networkmanager-sstp = p.networkmanager-sstp.override { withGnome = false; };
  };

  msg_q = f: p: { msg_q = inputs.msg_q.packages.${p.system}.default; };
  polars = f: p: {
    python3 = p.python3.override {
      packageOverrides = pf: pp: {
        polars = pp.polars.overrideAttrs (finalAttrs: previousAttrs: {
          env.RUSTFLAGS = "${previousAttrs.env.RUSTFLAGS} -Aunusued_imports";
          env.RUSTC_BOOTSTRAP = 1;
          env.CARGO_BUILD_JOBS = 1;
        });
      };
    };

  };
  plexpass = f: p:
    let version = "1.41.3.9314-a0bfb8370";
    in {
      plex = p.plex.override {
        plexRaw = p.plexRaw.overrideAttrs (o: {
          src = f.fetchurl {
            inherit version;
            url =
              "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
            sha256 = "sha256-ku16UwIAAdtMO1ju07DwuWzfDLg/BjqauWhVDl68/DI=";
          };
        });
      };
    };
}
