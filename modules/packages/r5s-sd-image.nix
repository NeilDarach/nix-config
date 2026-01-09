{ config, nixpkgs, pkgs, lib, inputs, ... }: {
  perSystem = per@{ inputs', pkgs, ... }:
    let
      image = config.flake.nixosConfigurations.r5s-sd;
      bootloader = pkgs.stdenvNoCC.mkDerivation {
        name = "nanopi-r5s-loader";
        src = pkgs.fetchurl {
          url = image.config.nanopi-r5s.bootloader.url;
          hash = image.config.nanopi-r5s.bootloader.hash;
        };
        nativeBuildInputs = [ pkgs.unzip ];
        dontPatch = true;
        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        unpackPhase = ''
          unzip $src -d src
        '';
        installPhase = ''
          mkdir -p $out
          cp src/idbloader.img $out/idbloader.img
          cp src/u-boot.itb $out/u-boot.itb
        '';
      };
    in {
      packages = {
        nanopi-r5s-image = pkgs.stdenv.mkDerivation {
          inherit bootloader;
          name = "nanopi-r5s-nixos";
          nativeBuildInputs = with pkgs; [ e2fsprogs util-linux xz ];
          rootfsImage = pkgs.callPackage
            "${toString inputs.nixpkgs}/nixos/lib/make-ext4-fs.nix" ({
              storePaths = image.config.system.build.toplevel;
              populateImageCommands = ''
                mkdir -p ./files/boot
                mkdir -p ./files/etc/nixos
                ${image.config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${image.config.system.build.toplevel} -d ./files/boot
                mkdir -p ./files/u-boot
                cp ${bootloader}/idbloader.img ./files/u-boot 
                cp ${bootloader}/u-boot.itb ./files/u-boot
                echo "dd conv=notrunc if=/u-boot/idbloader.img seek=8 of=/dev/??" > ./files/u-boot/readme.txt
                echo "dd conv=notrunc if=/u-boot/u-boot.itb seek=2048 of=/dev/??" >> ./files/u-boot/readme.txt
              '';
              volumeLabel = "NIXOS";
            });
          buildCommand = ''
            mkdir $out
            img=tmp.img
            #gap in front of the root partition (to fit uboot)
            gap=16
            #create the image file sized to fit bootloader, / and the gap
            rootSizeBlocks=$(du -B 512 --apparent-size $rootfsImage | awk '{ print $1 }')
            imageSize=$((rootSizeBlocks *512 + gap *1024 *1024))
            truncate -s $imageSize $img

            sfdisk --no-reread --no-tell-kernel $img <<EOF
              label: dos
              start=''${gap}M, type=83, bootable
            EOF

            eval $(partx $img -o START,SECTORS --nr 1 --pairs)
            dd conv=notrunc of=$img if=$rootfsImage seek=$START count=$SECTORS
            dd conv=notrunc of=$img if=${bootloader}/idbloader.img seek=8 
            dd conv=notrunc of=$img if=${bootloader}/u-boot.itb seek=2048 
            xz -vc $img > $out/nanopi-r5s-nixos.img.xz
            xz -t $out/nanopi-r5s-nixos.img.xz
          '';
        };
      };
    };
}

