{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-acme-darach =
      nixosArgs@{ pkgs, config, ... }:

      let
      in
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options = {
          local.acme-darach.enable = lib.mkEnableOption "Letsencrypt certificates for darach.org.uk";
        };
        config = lib.mkIf config.local.acme-darach.enable {
          sops.secrets = {
            "cloudflare/dns_tokens/darach" = { };
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
