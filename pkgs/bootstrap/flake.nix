{ 
  description = "A script to bootstrap the installation of a nixos system";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:/nixos/nixpkgs/nixos-23.11";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem ( system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
	packageName = "bootstrap";
      in {
        packages.${packageName} = pkgs.stdenv.mkDerivation {
	  name = "${packageName}";
	  src = self;
	  buildPhase = "";
	  installPhase = ''
	    mkdir -p $out/bin
	    cp bootstrap $out/bin
	  '';
	  };
	devShell = pkgs.mkShell { buildInputs = [ pkgs.${packageName} ]; };
        defaultPackage = self.packages.${system}.${packageName};
      }
    );
 }

