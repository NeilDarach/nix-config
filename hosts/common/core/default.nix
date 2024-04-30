{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.fps.nixosModules.programs-sqlite
      ./fish.nix
      ./sops.nix
      ./distributed-build.nix
      ./optin-persistence.nix
      ./openssh.nix
      ./security.nix
      ./locale.nix
      ./nix.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      just
      wget
      ;
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
    "net.ipv6.conf.lo.disable_ipv6" = 1;
    "net.ipv6.conf.eth0.disable_ipv6" = 1;
  };
  users.groups = {
    bluetooth = {};
  };
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  networking.domain = "darach.org.uk";
}
