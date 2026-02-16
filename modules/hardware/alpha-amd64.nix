{
  config,
  lib,
  inputs,
  ...
}:

{
  flake.modules = {
    nixos.hardware-amd64 =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ ];
        config = {
          boot.initrd.availableKernelModules = [
            "ata_piix"
            "uhci_hcd"
            "virtio_pci"
            "sr_mod"
            "virtio_blk"
          ];
          boot.initrd.kernelModules = [ ];
          boot.initrd.systemd.enable = true;
          boot.kernelModules = [ ];
          boot.extraModulePackages = [ ];
          nixpkgs.hostPlatform = "x86_64-linux";
        };
      };
  };
}
