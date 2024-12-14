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
  inherit
    (inputs.cardano-wallet.packages.${pkgs.stdenv.hostPlatform.system})
    cardano-address
    ;
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
