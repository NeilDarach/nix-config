{
  description = "Manage the eeprom on the rasberry pi 4";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    gen_init_cpio_src = {
      url =
        "https://raw.githubusercontent.com/torvalds/linux/refs/heads/master/usr/gen_init_cpio.c";
      flake = false;
    };
  };
  outputs = { self, nixpkgs,  gen_init_cpio_src, flake-utils, ... }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (p: f: { gen_init_cpio = self.packages.${system}.gen_init_cpio; })
          ];
        };
      in {
        packages.gen_init_cpio = pkgs.stdenv.mkDerivation {
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
