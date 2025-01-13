_default:
    @just --list

secrets:
    nix flake update secrets

see_secrets:
    sops --decrypt $SECRETS --input-type yaml  | less
