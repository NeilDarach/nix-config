{
  imports = [
    ./services
    ./hardware-configuration.nix
    ../common/core
    ../common/users/neil
    ../common/users/root
    ../common/users/guest
    ];

  networking = {
    hostName = "pi400";
    hostId = "95849595";
    useDHCP = true;
    };

  console.enable = true;
  system.stateVersion = "23.11";
  }
