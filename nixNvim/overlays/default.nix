inputs: let
  overlaySet = {

  };
  in
  builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet)
