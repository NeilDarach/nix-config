{
  config,
  nixpkgs,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  perSystem =
    {
      inputs',
      pkgs,
      ...
    }:
    let

      http-tarpit = pkgs.callPackage tarpit_fn { };
      tarpit_fn =
        {
          lib,
          buildGoModule,
          fetchFromGitHub,
        }:
        buildGoModule (finalAttrs: {
          pname = "http-tarpit";
          version = "1.0";
          src = fetchFromGitHub {
            owner = "die-net";
            repo = "http-tarpit";
            rev = "5bf21824ca3519e122b108fb2934e25f10b56d3e";
            hash = "sha256-rHwFculJ2issicWiCUsCAc1dod3iBJ6czRmCaFeXgVk=";
          };

          vendorHash = null;
          meta = {
            description = "Go-based tarpit for http connections";
            homepage = "https://github.com/die-net/http-tarpit";
            licence = lib.licenses.apsl20;
            maintainers = [ ];
          };
        });
    in
    {
      packages = { inherit http-tarpit; };
    };
}
