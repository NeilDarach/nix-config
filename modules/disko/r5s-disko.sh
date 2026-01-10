#!/usr/bin/env bash
set -eu
set -o pipefail

sudo nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko \
    -- \
    --mode disko \
    _r5s-disko.nix

curl --follow "https://github.com/inindev/u-boot-build/releases/download/2025.01/rk3568-nanopi-r5s.zip" >./tmp.zip
#unzip -p ./tmp.zip idbloader.img | sudo dd of=/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e seek=1
#unzip -p ./tmp.zip u-boot.itb | sudo dd of=/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e seek=2048
unzip -p ./tmp.zip u-boot-rockchip.bin | sudo dd of=/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e bs=32k seek=1 conv=fsync
rm ./tmp.zip
