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
  addressPkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [(import ../../overlays/cardano-addresses {inherit inputs;})];
  };
in {
  options = {
    cardano = {
      address = {
        enable = lib.mkEnableOption "Enable cardano-address" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.address.enable) {
    environment = {
      systemPackages = [
        addressPkgs.cardano-address
      ];
    };
  };
}
