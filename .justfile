_default:
    @just --list

rebuild HOST:
    nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}} --build-host localhost --use-remote-sudo 

deploy_r5s: 
    nixos-anywhere --flake .#r5s --target-host nix@nixos --phases disko,install,reboot --extra-files files/r5s --extra-commands "dd if=/mnt/u-boot-rockchip.bin of=/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e bs=32k seek=1 conv=fsync" --encryption-keys /keys/key.txt <(cat "${SECRETS}" | sops decrypt /dev/stdin --extract '["age_r5s"]' --input-type yaml) 


