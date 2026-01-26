{
  config,
  nixpkgs,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  configurations.nixos.rpi4-sd.module =
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
        "${inputs.nixpkgs}/nixos/modules/image/repart.nix"
        inputs.self.modules.nixos.hardware-rpi4
        inputs.self.modules.nixos.rpi4-repart
      ];

      # configuration.nix
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      environment.systemPackages = with pkgs; [
        vim
        git
      ];

      services.openssh.enable = true;
      networking.hostName = "nixos";
      users.users.nix = {
        password = "nix";
        isNormalUser = true;
        description = "nix";
        extraGroups = [
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
        ];
      };
      networking = {
        useDHCP = lib.mkForce true;
        hostId = "d9165afe";
      };

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      #-----
      #nixpkgs.config.allowUnfree = lib.mkDefault true;
      #hardware = {
      ##raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      #firmware = [ pkgs.linux-firmware ];
      #enableRedistributableFirmware = true;
      #};
      #console.enable = false;

      #boot = {
      #kernelParams = [
      #"console=tty0"
      #"earlycon=uart8250,mmio32,0xfe660000"
      #];
      #initrd.kernelModules = [
      #];
      #};
      #powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

      #local.useZfs = true;

      #boot.tmp.useTmpfs = true;
      #time.timeZone = "Europe/London";

      #environment.systemPackages = with pkgs; [
      #git
      #mc
      #psmisc
      #curl
      #wget
      #dig
      #file
      #nvd
      #ethtool
      #sysstat
      #neovim
      #dnsutils
      #jq
      #unzip
      #usbutils
      #lsof
      #];
      #
      #security.sudo.wheelNeedsPassword = false;
      #nix.settings.
      #i18n = {
      #defaultLocale = "en_GB.UTF-8";
      #};
      #environment.etc = {
      #"systemd/journald.conf.d/99-storage.conf".text = ''
      #[Journal]
      #Storage=volatile
      #'';
      #};
      #system.stateVersion = lib.mkDefault "25.11";
      #

    };
}
