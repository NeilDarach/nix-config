{ pkgs, lib, systemSettings, userSettings, nixos-hardware, ... }: {
  imports = [
    ../../system/hardware-configuration.nix
    ../../system/hardware/time.nix
    ../../system/hardware/bluetooth.nix
    ./pi.nix
    ];

  nix.nixPath = [ "nixos-config=$HOME/.dotfiles/system/configuration.nix" ];
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    '';

  nixpkgs.config.allowUnfree = true;


  networking.hostName = systemSettings.hostname;
  services.openssh.enable = true;


  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
    };

  environment.systemPackages = with pkgs; [
    neovim
    tmux
    git
    wget
    curl
    home-manager
    ];

  environment.shells = with pkgs; [ bash ];
  users.defaultUserShell = pkgs.bash;

  system.stateVersion = "23.11";
  }
