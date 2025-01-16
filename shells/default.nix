{ pkgs, inputs, outputs, ... }: {
  default = pkgs.mkShell {
    buildInputs = with pkgs; [ sops just ];
    shellHook =
      ''export SECRETS="${builtins.toString inputs.secrets}/secrets.yaml"'';
  };
}
