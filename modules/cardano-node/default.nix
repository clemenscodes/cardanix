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
in {
  imports = [
    inputs.cardano-node.nixosModules.cardano-node
    inputs.cardano-node.nixosModules.cardano-submit-api
  ];
  options = {
    cardano = {
      node = {
        enable = lib.mkEnableOption "Enable cardano-node" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.node.enable) {
    environment = {
      systemPackages = [
        pkgs.cardano-node
        pkgs.cardano-cli
        pkgs.cardano-submit-api
        pkgs.cardano-tracer
        pkgs.locli
        pkgs.db-analyser
        pkgs.bech32
      ];
    };
    services = {
      cardano-node = {
        enable = false;
      };
      cardano-submit-api = {
        enable = false;
      };
    };
  };
}
