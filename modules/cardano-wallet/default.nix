{pkgs, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
in {
  options = {
    cardano = {
      wallet = {
        enable = lib.mkEnableOption "Enable cardano-wallet" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.wallet.enable) {
    environment = {
      systemPackages = [pkgs.cardano-wallet];
    };
  };
}
