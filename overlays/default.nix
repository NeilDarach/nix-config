{inputs, ...}: {
  #Bring in custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # Set overlays
  modifications = final: prev: {
    pipewire = prev.pipewire.overrideAttrs (o: {
      patches = (o.patches or []) ++ [(./. + "/libcamera.patch")];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
