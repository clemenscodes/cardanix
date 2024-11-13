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
        enable = lib.mkEnableOption "Enable daedalus" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.daedalus.enable) {
    environment = {
      systemPackages = [inputs.daedalus.packages.${system}.default];
    };
  };
}
