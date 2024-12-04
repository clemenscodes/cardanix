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
  inherit (cardano-node) nodeId socketPath stateDirBase;
  inherit
    (inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment})
    networkConfig
    metadataUrl
    smashUrl
    ;
  walletHome = "${stateDirBase}${config.services.cardano-wallet.database}/${cfg.node.environment}";
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
      services = {
        cardano-wallet-fs = {
          after = ["local-fs.target"];
          before = ["cardano-node.service"];
          serviceConfig = {
            Type = "oneshot";
            User = "cardano-node";
            Group = "cardano-node";
            ExecStart = "mkdir -p ${walletHome}";
          };
        };
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
