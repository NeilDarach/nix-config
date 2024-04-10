{
  imports = [
    ./services
    ./hardware-configuration.nix
    ../common/global
    ../common/users/neil
    ../common/users/root
    ];

  networking = {
    hostName = "pi400";
    hostId = "95849595";
    useDHCP = true;
    };

  console.enable = true;
  system.stateVersion = "23.11";
  }
