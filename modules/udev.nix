{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.udev = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos; [ ];
      config = {
        services.udev = {
          enable = true;
          extraRules = ''
            # Detect a home-assistant yellow being plugged in recovery mode and allow members of plugdev to control it
            SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0002", GROUP="plugdev", MODE="0660"
            # Detect the result of rpiboot creating new block devices, set the group and create a symlink
            SUBSYSTEM=="block", ENV{ID_VENDOR}=="RPi-MSD-", GROUP="plugdev", MODE="0660", SYMLINK+="pi-msd%n"
            SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_USB_VENDOR}=="mmcblk0", GROUP="plugdev", MODE="0660", SYMLINK+="pi-emmc%n"
            SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_USB_VENDOR}=="nvme0n1", GROUP="plugdev", MODE="0660", SYMLINK+="pi-nvme%n"
            SUBSYSTEM=="tty",   ENV{ID_VENDOR_ID}=="0403", ENV{ID_USB_MODEL_ID}=="6001", GROUP="plugdev", MODE="0660"
            # Detect an Eaton UPS plugged in to a USB port and name it /dev/ups
            SUBSYSTEM=="usb", ATTRS{idVendor}=="0463", ATTRS{idProduct}=="ffff", GROUP="nut", MODE="0660", SYMLINK+="ups"
            # Detect the USB zigbee coordinator
            SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="/dev/zigbee-usb"
            # Detect the USB serial adapter
            SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", SYMLINK+="/dev/uart-usb"

          '';
        };
      };
    };
  };
}
