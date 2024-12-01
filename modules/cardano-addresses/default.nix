{pkgs, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
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
        pkgs.cardano-address
      ];
    };
  };
}
