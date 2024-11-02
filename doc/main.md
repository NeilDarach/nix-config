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


* Create a [boot config](../httpboot.conf) to download a boot.img from a webserver.<br>
``BOOT_ORDER`` is the important value here, which is set to HTTP<br>
If the network doesn't have a DCHP server, set the network address here.<br>
There should be a webserver running at the ``HTTP_HOST``

* Create a new signed eeprom based on the latest firmware, using the new boot.conf

        usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c httpboot.conf \
          -i usbboot/recovery/pieeprom.original.bin -o pieeprom-http.bin 

