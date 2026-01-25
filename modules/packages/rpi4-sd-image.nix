{
  config,
  nixpkgs,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    per@{ inputs', pkgs, ... }:
    {
      packages = {
        rpi4-image = inputs.nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          modules = [
            config.flake.modules.nixos.common-zfs
            ({
              local.useZfs = true;
              networking = {
                hostId = "d8165afe";
              };
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              time.timeZone = "Europe/London";
              environment.systemPackages = with pkgs; [
                git
                curl
                dnsutils
                jq
                unzip
                usbutils
                lsof
              ];
              security.sudo.wheelNeedsPassword = false;
              nix.settings.trusted-users = [
                "root"
                "@wheel"
              ];
              users.users.nix = {
                isNormalUser = true;
                description = "nix";
                extraGroups = [
                  "networkmanager"
                  "wheel"
                ];
                password = "nix";
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
                ];
              };
              services.openssh.enable = true;
              i18n = {
                defaultLocale = "en_GB.UTF-8";
              };
              system.stateVersion = lib.mkDefault "25.11";
              image.baseName = "nixos-rpi4-sd";
              image.filePath = config.image.fileName;
            })
          ];
        };
      };
    };
}
