{
  imports = [
    ./services
    ./hardware-configuration.nix
    ../common/core
    ../common/users/neil
    ];

  networking = {
    hostName = "yellow";
    hostId = "95849593";
    useDHCP = true;
    };

  console.enable = true;
  system.stateVersion = "23.11";
  }
