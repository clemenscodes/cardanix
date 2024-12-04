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
  inherit (cardano-node) nodeId socketPath stateDir dbPrefix;
  inherit
    (inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment})
    networkConfig
    metadataUrl
    smashUrl
    ;
  walletHome = "${stateDir nodeId}/${dbPrefix nodeId}/${config.services.cardano-wallet.database}";
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
        poolMetadataFetching = {
          inherit (cfg.wallet) enable;
          inherit smashUrl;
        };
        tokenMetadataServer = metadataUrl;
      };
    };
    systemd = {
      tmpfiles = {
        rules = [
          "d ${config.services.cardano-node.stateDir config.services.cardano-node.nodeId} 0775 cardano-node cardano-node -"
          "d ${walletHome} 0775 cardano-node cardano-node -"
        ];
      };
      services = {
        cardano-wallet = {
          after = ["cardano-node.service"];
          serviceConfig = {
            DynamicUser = lib.mkForce "no";
            WorkingDirectory = walletHome;
            User = "cardano-node";
            Group = "cardano-node";
            TimeoutStartSec = "infinity";
            Restart = "always";
            RestartSec = 1;
          };
        };
      };
    };
    environment = {
      systemPackages = [pkgs.cardano-wallet];
      variables = {
        STATE_DIRECTORY = walletHome;
      };
    };
  };
}
