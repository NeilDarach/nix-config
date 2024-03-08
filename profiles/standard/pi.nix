# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).


{ config, lib, nixpkgs, pkgs, nixos, nixos-hardware, raspberry-pi-nix, ... }:

{
  imports =
    [ 
      ../../system/hardware-configuration.nix
    ];
#  modules = [
#    raspberry-pi-nix.nixosModules.raspberry-pi 
#    ];

  nixpkgs.overlays = [ 
    (final: prev: {
      pipewire = prev.pipewire.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [ (./. + "/libcamera.patch") ];
	});
      })
    ];

  hardware = {
    #raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    #deviceTree = {
    #  enable = true;
    #  filter = "*rpi-4-*.dtb";
    #};
    bluetooth.enable = true;
    raspberry-pi = {
      config = {
        all = {
	  base-dt-params = {
	    krnbt = {
	      enable = true;
	      value = "on";
	      };
	    };
          };
	};
      };
  };

  console.enable = true;

  boot = {
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
      };
    supportedFilesystems = [ "zfs" "ext4" ];
    };

  boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;

  networking.hostId = "95849594";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  #hardware.raspberry-pi."4".audio.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;
}

