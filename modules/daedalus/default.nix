{inputs, ...}: {
  system,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cardano;
  daedalus = import ./daedalus.nix {inherit inputs config pkgs system;};
in {
  options = {
    cardano = {
      daedalus = {
        enable = lib.mkEnableOption "Enable daedalus" // {default = false;};
        home = lib.mkOption {
          type = lib.types.path;
          default = "";
        };
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.daedalus.enable) {
    environment = {
      systemPackages = [daedalus];
    };
  };
}
