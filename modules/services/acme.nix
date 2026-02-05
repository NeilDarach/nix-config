{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-acme =
      nixosArgs@{ pkgs, config, ... }:

      let
      in
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options = {
          local.acme.enable = lib.mkEnableOption "Haproxy instance to handle dynamic service hostnames";
        };
        config = lib.mkIf config.local.acme.enable {
          sops.secrets = {
            cloudflare_dns_token = { };
            cloudflare_account_id = { };
            cloudflare_zone_id_darach = { };
          };
          sops.templates."cloudflare-acme-darach" = {
            content = ''
              CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_dns_token}
            '';
          };

          security.acme = {
            acceptTerms = true;
            defaults.email = "neil.darach@gmail.com";
            certs."darach.org.uk" = {
              domain = "darach.org.uk";
              extraDomainNames = [ "*.darach.org.uk" ];
              dnsProvider = "cloudflare";
              dnsResolver = "1.1.1.1:53";
              environmentFile = "${config.sops.templates."cloudflare-acme-darach".path}";
            };
          };
        };
      };
  };
}
