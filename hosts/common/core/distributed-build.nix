{

  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "nixos-build";
      systems = [ "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 4;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];

  services.openssh = {
    knownHosts = {
      nixos-build.hostNames = [ "nixos-build.darach.org.uk" ];
      nixos-build.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1";
      };
    };

    programs.ssh.extraConfig = ''
Host nixos-build
    HostName nixos-build.darach.org.uk
    port 22
    user neil
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_nixos-build
    AddressFamily inet
    '';
  }
