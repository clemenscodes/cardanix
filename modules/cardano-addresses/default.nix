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
  cardano-address = inputs.capkgs.packages.${pkgs.stdenv.hostPlatform.system}.cardano-address-cardano-foundation-cardano-wallet-v2024-11-18-9eb5f59;
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
      systemPackages = [cardano-address];
    };
  };
}
