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
    bech32
    ;
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
      systemPackages = [bech32];
    };
  };
}
