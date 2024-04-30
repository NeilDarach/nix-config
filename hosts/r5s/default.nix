{
  imports = [
    ./services
    ./hardware-configuration.nix
    ../common/core
    ../common/optional/podman
    ../common/users/neil
    ../common/users/root
  ];

  networking = {
    hostName = "r5s";
    hostId = "95849596";
    useDHCP = true;
  };

  console.enable = true;
  system.stateVersion = "23.11";
}
