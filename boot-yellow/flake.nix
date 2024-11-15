{
  description = "Manage the eeprom on the rasberry pi 4";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen_init_cpio_src = {
      url =
        "https://raw.githubusercontent.com/torvalds/linux/refs/heads/master/usr/gen_init_cpio.c";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, gen_init_cpio_src, flake-utils
    , ... }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import nixpkgs-unstable { inherit system; };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (p: f: { gen_init_cpio = self.packages.${system}.gen_init_cpio; })
          ];
        };
      in {
        packages = {
          gen_init_cpio = pkgs.stdenv.mkDerivation {
            name = "gen_init_cpio";
            version = "1.0";
            src = gen_init_cpio_src;
            dontUnpack = true;
            buildPhase = ''
              mkdir -p $out/bin
              $CC -x c "$src" -o $out/bin/gen_init_cpio
            '';
            installPhase = "";
          };
          yellow_boot64 = let
            piPkgs = import nixpkgs { system = "aarch64-linux"; };
            key = builtins.readFile "/home/neil/.ssh/id_rsa";
            static =
              unstable.pkgsCross.aarch64-multiplatform.pkgsMusl.pkgsStatic;
            kernel = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [
                "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                ({ ... }: {
                  nixpkgs.hostPlatform = "aarch64-linux";
                  boot.kernelPackages = piPkgs.linuxPackages_rpi4;
                })
              ];
            };
          in pkgs.stdenv.mkDerivation {
            name = "yellow_boot64";
            version = "1.0";
            buildInputs = [
              pkgs.zstd
              pkgs.gen_init_cpio
              pkgs.bash
              pkgs.unixtools.xxd
              pkgs.coreutils
              pkgs.openssl
              pkgs.raspberrypi-eeprom
              pkgs.mtools
            ];
            src = ./.;
            buildPhase = ''
              echo "Build dir is $PWD"
              mkdir -p boot
              mkdir -p initramfs.d/{bin,dev,etc,lib,lib64,mnt/root,proc,root,sbin,sys,var/run}
              mkdir -p initramfs.d/etc/network/{if-up.d,if-pre-up.d,if-down.d,if-pre-down.d,if-post-down.d,if-post-up.d}
              mkdir -p initramfs.d/usr/local/crossware/etc/dropbear
              cp -r ${kernel.config.system.build.kernel}/dtbs/broadcom/* boot
              cp -r ${kernel.config.system.build.kernel}/dtbs/overlays boot/overlays
              cp -r ${kernel.config.system.build.kernel}/Image boot
              #cp -r --no-preserve=ownership,mode ${kernel.config.system.build.kernel}/lib initramfs.d
              #rm -rf initramfs.d/lib/modules/6.1.63/kernel/sound
              #rm -rf initramfs.d/lib/modules/6.1.63/kernel/crypto
              #rm -rf initramfs.d/lib/modules/6.1.63/kernel/drivers
              cp ${static.dropbear}/bin/* initramfs.d/bin
              cp ${static.busybox}/bin/busybox initramfs.d/bin
              cp ${static.busybox}/default.script initramfs.d/etc/network/udhcpc.script
              sed -i initramfs.d/etc/network/udhcpc.script -e "s/\/nix.*\/bin/\/bin/"
              cp ${static.gnutar}/bin/* initramfs.d/bin
              cp -r $src/ssh64/boot/* boot
              cp -r $src/ssh64/root/* initramfs.d
              gen_init_cpio <(sh  $src/gen_initramfs_list.sh initramfs.d ; cat $src/ssh64/cpio-*.txt) | gzip -9 > boot/rootfs.cpio

              dd if=/dev/zero of=boot.img bs=1M count=42
              mformat -i boot.img -F ::
              mcopy -s -i boot.img boot/* ::
              echo "${key}" > key
              rpi-eeprom-digest -i boot.img -o boot.sig -k "key"
            '';
            fixupPhase = "echo 'Skipping fixup'";
            installPhase = ''
              echo "Install dir is $PWD"
              mkdir -p $out/{boot,initramfs.d}
              cp -r boot $out
              cp -r initramfs.d $out
              cp boot.img boot.sig $out
            '';
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.pip
            pkg-config
            libusb
            xxd
            just
            mtools
            zstd
            screen
            gen_init_cpio
          ];
          shellHook = ''
            python -m venv .venv
            source .venv/bin/activate
            pip install -q -r requirements.txt
            export KEY_FILE=~/.ssh/id_rsa
          '';
        };
      }));
}
