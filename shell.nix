{ pkgs, inputs, outputs, ... }: {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [ just ];
    shellHook =
      ''export SECRETS="${builtins.toString inputs.secrets}/secrets.yaml"'';
  };
}
