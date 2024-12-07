{
  inputs,
  pkgs,
  ...
}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
  bech32Pkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [(import ../../overlays/bech32 {inherit inputs;})];
  };
in {
  options = {
    cardano = {
      bech32 = {
        enable = lib.mkEnableOption "Enable bech32" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment = {
      systemPackages = [
        bech32Pkgs.bech32
      ];
    };
  };
}
