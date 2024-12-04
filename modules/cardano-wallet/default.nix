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
  inherit (config.services) cardano-node;
  inherit (cardano-node) nodeId socketPath;
  stateDir = cardano-node.stateDir nodeId;
  inherit
    (inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment})
    networkConfig
    metadataUrl
    smashUrl
    ;
in {
  imports = ["${inputs.cardano-wallet}/nix/nixos"];
  options = {
    cardano = {
      wallet = {
        enable = lib.mkEnableOption "Enable cardano-wallet" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.node.enable && cfg.wallet.enable) {
    services = {
      cardano-wallet = {
        inherit (cfg.wallet) enable;
        listenAddress = "0.0.0.0";
        package = pkgs.cardano-wallet;
        nodeSocket = socketPath nodeId;
        genesisFile =
          if cfg.node.environment != "mainnet"
          then networkConfig.ByronGenesisFile
          else null;
        database = lib.removePrefix stateDir;
        poolMetadataFetching = {
          inherit (cfg.wallet) enable;
          inherit smashUrl;
        };
        tokenMetadataServer = metadataUrl;
      };
    };
    environment = {
      systemPackages = [pkgs.cardano-wallet];
      variables = {
        STATE_DIR = stateDir;
      };
    };
  };
}
