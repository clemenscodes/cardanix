{pkgs, ...}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
in {
  options = {
    cardano = {
      node = {
        enable = lib.mkEnableOption "Enable cardano-node" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.node.enable) {
    environment = {
      systemPackages = [pkgs.cardano-node];
    };
  };
}
