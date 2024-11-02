# Install Nixos on the Home Assistant Yellow
* Set up the repository to contain all the steps

        git init nixos-yellow


* We're going to need updated firmware, so add the Raspberry Pi firmware repository as a submodule

        cd nixos-yellow
        git submodule add https://github.com/raspberrypi/usbboot

* The usbboot repo also contains submodules, so check everything out

        git submodule update --init --recursive

* Create a [flake](../flake.nix) to keep track of all the extra software needed, and load it automatically with devenv
[]
