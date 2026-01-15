{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.distributedBuilds =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ ];
        options.local = {
          useDistributedBuilds = lib.mkEnableOption "builds on various other hosts";
        };
        config = lib.mkIf config.local.useDistributedBuilds {
          nix.distributedBuilds = true;
          nix.buildMachines = [
            {
              hostName = "eu.nixbuild.net";
              system = "aarch64-linux";
              maxJobs = 10;
              speedFactor = 2;
              supportedFeatures = [
                "benchmark"
                "big-parallel"
              ];
            }
            {
              hostName = "eu.nixbuild.net";
              system = "x86_64-linux";
              maxJobs = 10;
              speedFactor = 2;
              supportedFeatures = [
                "benchmark"
                "big-parallel"
              ];
            }
          ];
          programs.ssh = {
            extraConfig = ''
              Host eu.nixbuild.net
                PubKeyAcceptedKeyTypes ssh-ed25519
                ServerAliveInterval 60
                IPQos throughput
                IdentityFile ~/.ssh/id_nixbuild
            '';
            knownHosts = {
              nixbuild = {
                hostNames = [ "eu.nixbuild.net" ];
                publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
              };
            };
          };
        };
      };
  };
}
