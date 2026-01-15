{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.udev =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        config = {
          services.udev = {
            enable = true;
            extraRules = ''
              # Detect a home-assistant yellow being plugged in recovery mode and allow members of
              SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0002", GROUP="plugdev"
              # Detect the result of rpiboot creating new block devices, set the group and create
              SUBSYSTEM=="block", ENV{ID_VENDOR}=="RPi-MSD-", GROUP="plugdev", MODE="0660", SYMLIN
              SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_
              SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_
              SUBSYSTEM=="tty",   ENV{ID_VENDOR_ID}=="0403", ENV{ID_USB_MODEL_ID}=="6001", GROUP="
              # Detect an Eaton UPS plugged in to a USB port and name it /dev/ups
              SUBSYSTEM=="usb", ATTRS{idVendor}=="0463", ATTRS{idProduct}=="ffff", GROUP="nut", MO
            '';
          };
        };
      };
  };
}
