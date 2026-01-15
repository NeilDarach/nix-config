{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.hardware-intel =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        config = {
          boot = {
            initrd = {
              availableKernelModules = [
                "xhci_pci"
                "ehci_pci"
                "ata_piix"
                "usbhid"
                "usb_storage"
                "uas"
                "sd_mod"
              ];
              systemd.enable = true;
            };
            kernelModules = [ "kvm-intel" ];
            zfs = {
              allowHibernation = false;
            };
          };
          nixpkgs.hostPlatform = "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
      };
  };
}
