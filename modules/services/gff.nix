{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-gff =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
          inputs.gff.nixosModules.default
        ];
        options = {
          local.gff.enable = lib.mkEnableOption "Glasgow Film Festival calendar updates";
        };
        config = lib.mkIf config.local.gff.enable {
          gff.enable = true;
          sops = {
            secrets = {
              "gff-google-calendar-auth" = {
                owner = "gff";
              };
              "gff-filter-id" = { };
              "gff-full-id" = { };
            };

            templates."gff-google-calendar-env" = {
              owner = "gff";
              content = ''
                GFF_AUTH=${config.sops.secrets.gff-google-calendar-auth.path}
                GFF_FILTER_ID=${config.sops.placeholder.gff-filter-id}
                GFF_FULL_ID=${config.sops.placeholder.gff-full-id}
                GFF_CALLBACK="https://goip.org.uk/gff/change"
              '';
            };
          };
          gff.envFile = "${config.sops.templates."gff-google-calendar-env".path}";

        };
      };
  };
}
