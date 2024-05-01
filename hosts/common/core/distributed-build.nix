{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "nixos-build";
      systems = ["aarch64-linux"];
      maxJobs = 8;
      speedFactor = 4;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    }
    {
      hostName = "nixbuild-net";
      systems = ["aarch64-linux" "x86_64-linux"];
      maxJobs = 100;
      speedFactor = 8;
      supportedFeatures = ["benchmark" "big-parallel"];
    }
  ];

  services.openssh = {
    knownHosts = {
      nixos-build = {
        hostNames = ["nixos-build.darach.org.uk"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1";
      };
      nixbuild-net = {
        hostNames = ["eu.nixbuild.net"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
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
    Host nixbuild-net
        HostName eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile ~/.ssh/id_nixos-build
  '';
}
