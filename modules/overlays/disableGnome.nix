{ inputs, ... }:
{
  flake.modules.nixos.overlays-disableGnome =
    nixosArgs@{ pkgs, config, ... }:
    {
      nixpkgs.overlays = [
        (final: previous: {
          networkmanager-l2tp = previous.networkmanager-l2tp.override { withGnome = false; };
          networkmanager-openconnect = previous.networkmanager-openconnect.override { withGnome = false; };
          #networkmanager-vpnc =previous.networkmanager-vpnc.override { withGnome = false;
          networkmanager-iodine = previous.networkmanager-iodine.override { withGnome = false; };
          networkmanager-openvpn = previous.networkmanager-openvpn.override { withGnome = false; };
          networkmanager-libnma = previous.networkmanager-libnma.override { withGnome = false; };
          networkmanager-fortislvpn = previous.networkmanager-fortislvpn.override { withGnome = false; };
          networkmanager-sstp = previous.networkmanager-sstp.override { withGnome = false; };
        })
      ];
    };
}
