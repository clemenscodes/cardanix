{pkgs, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
in {
  options = {
    cardano = {
      cli = {
        enable = lib.mkEnableOption "Enable cardano-cli" // {default = cfg.enable;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment = {
      systemPackages = [pkgs.cardano-cli];
    };
  };
}
