_default:
    @just --list

test:
    sudo nixos-rebuild test --flake . 

rebuild HOST:
    nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}} --build-host localhost --use-remote-sudo

deploy_r5s:
    # Use nixos-anywhere to partition the target disks according to the disko specs
    echo nixos-anywhere --flake .#r5s --target-host nix@nixos --phases disko
    # Extract the eMMC dev name from the flake and write the r5s-specific u-boot booloader to it
    cat files/r5s/u-boot-rockchip.bin | ssh nix@nixos "sudo dd of=$(nix --extra-experimental-features 'nix-command flakes' eval --raw .#nixosConfigurations.r5s.config.disko.devices.disk.emmc.device 2>/dev/null) bs=32k seek=1 conv=fsync"
    # Extract the age key for the host from secrets and make it available to the new host
    (cat "${SECRETS}" | sops decrypt /dev/stdin --extract '["age_r5s"]' --input-type yaml) | ssh nix@nixos "sudo dd of=/mnt/keys/key.txt"
    # Finish the build with nixos-anywhere.  No need to reboot as the sd card needs to be removed anyway
    nixos-anywhere --flake .#r5s --target-host nix@nixos --phases install


