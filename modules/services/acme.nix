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
            "cloudflare/dns_tokens/darach" = { };
            "cloudflare/account_id" = { };
            "cloudflare/zone_ids/darach" = { };
          };
          sops.templates."cloudflare-acme-darach" = {
            content = ''
              CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/dns_tokens/darach"}
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
