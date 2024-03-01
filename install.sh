#!/bin/bash 

nix-shell -p git --command "git clone https://github.com/NeilDarach/nix-config ~/.dotfiles"
sudo nixos-generate-config --show-hardware-config > ~/.dotfiles/system/hardware-configuration.nix

sudo nixos-rebuild switch --flake ~/.dotfiles#system;
nix run home-manager/master --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.dotfiles#user;


