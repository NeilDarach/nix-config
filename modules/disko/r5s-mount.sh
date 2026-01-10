#!/usr/bin/env bash
set -eu
set -o pipefail

sudo nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko \
    -- \
    --mode mount \
    _r5s-disko.nix
