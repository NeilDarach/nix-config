# Install Nixos on the Home Assistant Yellow
* Set up the repository to contain all the steps

        git init nixos-yellow


* We're going to need updated firmware, so add the Raspberry Pi firmware repository as a submodule

        cd nixos-yellow
        git submodule add https://github.com/raspberrypi/usbboot

* The usbboot repo also contains submodules, so check everything out

        git submodule update --init --recursive

* Create an empty [flake](../flake.nix) to keep track of all the extra software needed, and load it automatically with [devenv](../.envrc)

        {
          description = "Manage the eeprom on the rasberry pi 4";

          inputs = {
            nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
            flake-utils.url = "github:numtide/flake-utils";
          };
          outputs = { self, nixpkgs, flake-utils, ... }@inputs:
            (flake-utils.lib.eachDefaultSystem (system:
              let pkgs = import nixpkgs { inherit system; };
              in {
                devShells.default = pkgs.mkShell {
                  buildInputs = with pkgs; [ ];
                  shellHook = ''
                  '';
                };
              }));
        }

* An RSA private key and python crypto libraries are needed to sign boot images,  and
the scripts need xxd, so add those to the flake

        buildInputs = with pkgs; [ python3 python3Packages.pip xxd ];
        shellHook = ''
            python -m venv .venv
            source .venv/bin/activate
            pip install  -q -r requirements.txt
            export KEY_FILE=~/.ssh/id_rsa
            '';
        
* And add a requirements.txt with the version of pycryptodomex to install

        pycryptodomex==3.21.0


* The firmware binaries need libusb to build, so add those to the flake, along with pkg-config so they can be found

        buildInputs = with pkgs; [ python3 python3Packages.pip pkg-config libusb ];

* Build the firmware binaries

        cd usbboot; make


* Create a [boot config](../pieeprom-http/boot.conf) to download a boot.img from a webserver.<br>
``BOOT_ORDER`` is the important value here, which is set to HTTP<br>
If the network doesn't have a DCHP server, set the network address here.<br>
There should be a webserver running at the ``HTTP_HOST``<br>
Link the important startup files from usbboot

        ln -s ../usbboot/recovery/bootcode4.bin pieeprom-http
        ln -s ../usbboot/recovery/config.txt pieeprom-http

* Create a new signed eeprom based on the latest firmware, using the new boot.conf

        usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c httpboot.conf \
          -i usbboot/recovery/pieeprom.original.bin -o pieeprom-http/pieeprom.bin 

* That should create pieeprom.bin and pieeprom.sig which can now be flashed to the Pi<br>
Connect the jumpers to enter service mode on power-on and connect the USB-C port to the computer.

        usbboot/rpiboot -v -d pieeprom-http


* Save typing in the future by creating a justfile to keep track of these long commands<br>
Add ``just`` to the flake's buildInputs and create a new file ``.justfile``

        _default:
            @just --list

        # Rebuild the httpboot eeprom and flash it to the pi
        httpboot:
            usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c pieeprom-http/boot.conf \
            -i usbboot/recovery/pieeprom.original.bin -o pieeprom-http/pieeprom.bin \
            && usbboot/rpiboot -v -d pieeprom-http

* Create a FAT32 filesystem that will be used to boot the pi, sign it and make it 
avilable on the webserver.<br>
It will be empty for now, but the Pi should find it an try to boot from it.<br>
This needs ``mtools`` added to the flake.<br>
The maximum size of a pi boot.img is 96Mb, so limit it there.

        mkdir -p boot
        touch boot/config.txt
        dd if=/dev/zero of=boot.img bs=1M count=95
        mformat -i boot.img -F ::
        mcopy -s -i boot.img boot/* ::
        usbboot/tools/rpi-eeprom-digest -i boot.img -o boot.sig -k "$KEY_FILE"
        cp boot.img boot.sig /var/lib/nginx/www/pi/yellow

* Extract necessary boot files from the mass_storage_gadget boot imagt
    
        dd if=usbboot/mass-storage-gadget/boot.img bs=512 skip=1 of=msg.img
        mkdir -p boot.tmp
        mcopy -s -i msg.img :: boot.tmp
        mv boot.tmp/rootfs.cpio.zst .
        rm boot.tmp/config.txt
        cp -r boot.tmp/* boot
        rm msg.img
        rm -rf boot.tmp

* Build a modified initramfs based on rootfs.cpio.zst (needs ``zstd`` in the flake to uncompress)

        mkdir -p initramfs.d
        (cd initramfs.d ; zstdcat ../rootfs.cpio.zst | cpio -i -f dev/console)
        sudo mknod -m 600 initramfs.d/dev/console c 5 1
        cp -r initramfs.changes/* initramfs.d
        (cd initramfs.d ; find . -print0 | cpio --null --create --format=newc | zstd > ../boot/rootfs.cpio.zstd) 
