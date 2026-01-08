{ config, nixpkgs, pkgs, lib, inputs, ... }: {
  perSystem = per@{ inputs', pkgs, ... }: {
    devShells = let secrets = inputs.secrets;
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [ sops just ];
        shellHook = ''
          export SECRETS="${builtins.toString secrets}/secrets.yaml"
        '';
      };
    };
  };
}

