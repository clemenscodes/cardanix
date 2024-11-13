{inputs, ...}: {
  system,
  config,
  lib,
  ...
}: let
  cfg = config.cardano;
in {
  options = {
    cardano = {
      daedalus = {
        enable = lib.mkEnableOption "Enable daedalus" // {default = cfg.enable;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment = {
      systemPackages = [inputs.daedalus.packages.${system}.default];
    };
  };
}
