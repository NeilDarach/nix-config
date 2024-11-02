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

* An RSA private key and python crypto libraries are needed to sign boot images, so add those to the flake

        buildImputs = with pkgs; [ python3 python3Packages.pip ];
        shellHook = ''
            python -m venv .venv
            source .venv/bin/activate
            pip install  -q -r requirements.txt
            export KEY_FILE=~/.ssh/id_rsa
            '';
        
* And add a requirements.txt with the version of pycryptodomex to install

        pycryptodomex==3.21.0
