{ outputs, inputs, ... }: {
  local_packages = f: p: import ../packages { pkgs = f; };
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
}
