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
  inherit (cfg.daedalus) home;
  daedalusPkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [(import ../../overlays/daedalus {inherit inputs pkgs home;})];
  };
in {
  options = {
    cardano = {
      daedalus = {
        enable = lib.mkEnableOption "Enable daedalus" // {default = false;};
        home = lib.mkOption {
          type = lib.types.str;
          default = "$XDG_DATA_HOME/Daedalus";
        };
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.daedalus.enable) {
    environment = {
      systemPackages = [daedalusPkgs.daedalus];
    };
  };
}
