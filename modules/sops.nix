{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.sops = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos;
        [ inputs.sops-nix.nixosModules.sops ];
      config = {
        sops = {
          age.keyFile = "/keys/key.txt";
          defaultSopsFormat = "yaml";
          defaultSopsFile = "${builtins.toString inputs.secrets}/secrets.yaml";
        };
      };
    };
  };
}
