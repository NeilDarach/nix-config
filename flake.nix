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
          buildInputs = with pkgs; [ python3 python3Packages.pip ];
          shellHook = ''
            python -m venv .venv
            source .venv/bin/activate
            pip install -q -r requirements.txt
            export KEY_FILE=~/.ssh/id_rsa
          '';
        };
      }));
}
