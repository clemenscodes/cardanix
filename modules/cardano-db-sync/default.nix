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
  dbSyncPkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [(import ../../overlays/cardano-db-sync {inherit inputs;})];
  };
in {
  imports = ["${inputs.cardano-db-sync}/nix/nixos"];
  options = {
    cardano = {
      db-sync = {
        enable = lib.mkEnableOption "Enable cardano-db-sync" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.db-sync.enable) {
    environment = {
      systemPackages = [
        dbSyncPkgs.cardano-db-sync
      ];
    };
    services = {
      cardano-db-sync = {
        enable = false;
      };
      smash = {
        enable = false;
      };
    };
  };
}
