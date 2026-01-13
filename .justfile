_default:
    @just --list

rebuild HOST:
    nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}} --build-host localhost --use-remote-sudo

deploy_r5s:
    nixos-anywhere --flake .#r5s --target-host nix@nixos --phases disko
    cat files/r5s/u-boot-rockchip.bin | ssh nix@nixos "sudo dd of=/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e bs=32k seek=1 conv=fsync"
    (cat "${SECRETS}" | sops decrypt /dev/stdin --extract '["age_r5s"]' --input-type yaml) | ssh nix@nixos "sudo dd of=/mnt/keys/key.txt"
    nixos-anywhere --flake .#r5s --target-host nix@nixos --phases install,reboot


