{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.sops =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ inputs.sops-nix.nixosModules.sops ];
        config = {
          sops = {
            age.keyFile = "/keys/key.txt";
            age.generateKey = false;
            defaultSopsFormat = "yaml";
            defaultSopsFile = "${builtins.toString inputs.secrets}/secrets.yaml";
          };
          systemd.tmpfiles.rules = [
            "f ${config.sops.age.keyFile} 0640 root root"
            "d ${builtins.dirOf config.sops.age.keyFile} 0750 root root"
          ];
        };
      };
  };
}
