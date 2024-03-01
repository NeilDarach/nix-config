# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/raspberry-pi/4>
      ./hardware-configuration.nix
    ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  console.enable = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
      };
    supportedFilesystems = [ "zfs" "ext4" ];
    };

  networking.hostName = "pi400"; # Define your hostname.
  networking.hostId = "95849594";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  #hardware.raspberry-pi."4".audio.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    neil = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtxI6NN+HDc9e2tnPo6VEb2srUoE8aUd0dls1MgPiEAAF+Gn198NlcT33ysmbR7SCfL79cTuPsjqpoR/7p+hv53jmaxht+qO7eybhwW3ZbjjsQCK5162xR7d3/kwDlldy4DEgk0lPYF6RlM7Uf+bDiHjHs7Ypvd+COTItkFBjVdYFANbeDjw4iWo/i0w52FVqtXZvvUsH6ozS1Ed8ueJVY4YmKdi2YEBLUtzep0THOoqdB6ZeRreKAp/jUlJKxiHmAn9WDCcMakWY/f0eQeJyXa7ioLLXQwRJmaAx0fyCqSZ2RmNAUT8rf9TQGGpvm7XuNCqrZxjez/OZ5UvCrwYR2Q== neil@neil-dobsons-powerbook-g4-15.local"
    ];
    packages = with pkgs; [
      firefox
      tree
    ];
    };

  root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtxI6NN+HDc9e2tnPo6VEb2srUoE8aUd0dls1MgPiEAAF+Gn198NlcT33ysmbR7SCfL79cTuPsjqpoR/7p+hv53jmaxht+qO7eybhwW3ZbjjsQCK5162xR7d3/kwDlldy4DEgk0lPYF6RlM7Uf+bDiHjHs7Ypvd+COTItkFBjVdYFANbeDjw4iWo/i0w52FVqtXZvvUsH6ozS1Ed8ueJVY4YmKdi2YEBLUtzep0THOoqdB6ZeRreKAp/jUlJKxiHmAn9WDCcMakWY/f0eQeJyXa7ioLLXQwRJmaAx0fyCqSZ2RmNAUT8rf9TQGGpvm7XuNCqrZxjez/OZ5UvCrwYR2Q== neil@neil-dobsons-powerbook-g4-15.local"
    ];
  };
  };
    

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim 
    docker
    direnv
    tmux
    wget
    libraspberrypi
    raspberrypi-eeprom
    zfs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

