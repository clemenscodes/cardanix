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
  dbSyncPkgs = inputs.cardano-db-sync.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  socketPath = config.services.cardano-node.socketPath config.services.cardano-node.nodeId;
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
      systemPackages = [pkgs.cardano-db-sync];
    };
    services = {
      cardano-db-sync = {
        enable = false;
        inherit dbSyncPkgs socketPath;
        cluster = cfg.node.environment;
        package = pkgs.cardano-db-sync;
        # TODO: stateDir = "/var/lib/cexplorer";
        postgres = {};
      };
      smash = {
        enable = false;
      };
    };
  };
}
