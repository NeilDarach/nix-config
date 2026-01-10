{ config, nixpkgs, pkgs, lib, inputs, ... }: {
  perSystem = per@{ inputs', pkgs, ... }: {
    devShells = let
      secrets = inputs.secrets;
      patched-nixos-anywhere = pkgs.nixos-anywhere.overrideAttrs (o: {
        patches = (o.patches or [ ])
          ++ [ ./_nixos-anywhere-encryption-keys.diff ];
      });
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [ sops just patched-nixos-anywhere ];
        shellHook = ''
          export SECRETS="${builtins.toString secrets}/secrets.yaml"
        '';
      };
    };
  };
}

