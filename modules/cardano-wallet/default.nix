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
  inherit (cardano-node) nodeId stateDirBase;
  inherit
    (inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment})
    networkConfig
    metadataUrl
    smashUrl
    ;
  socketPath = config.services.cardano-node.socketPath config.services.cardano-node.nodeId;
  walletHome = "${stateDirBase}${config.services.cardano-wallet.database}/${cfg.node.environment}";
  cardano-wallet-fs = pkgs.writeShellScriptBin "cardano-wallet-fs" ''
    if [ ! -d "${walletHome}" ]; then
      mkdir -p ${walletHome}
    fi

    current_owner=$(stat -c '%U:%G' "${stateDirBase}${config.services.cardano-wallet.database}" 2>/dev/null)

    if [ "$current_owner" != "cardano-node:cardano-node" ]; then
    chown -R cardano-node:cardano-node ${stateDirBase}${config.services.cardano-wallet.database}
    fi

    current_perms=$(stat -c '%a' "${stateDirBase}${config.services.cardano-wallet.database}" 2>/dev/null)
    if [ "$current_perms" != "755" ]; then
      chmod -R 0755 ${stateDirBase}${config.services.cardano-wallet.database}
    fi
  '';
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
    environment = {
      systemPackages = [pkgs.cardano-wallet];
      variables = {
        STATE_DIRECTORY = walletHome;
        STATE_DIR = walletHome;
      };
    };
    services = {
      cardano-wallet = {
        inherit (cfg.wallet) enable;
        listenAddress = "0.0.0.0";
        package = pkgs.cardano-wallet;
        nodeSocket = socketPath nodeId;
        walletMode =
          if cfg.node.environment == "mainnet"
          then "mainnet"
          else "testnet";
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
          after = ["local-fs.target" "cardano-node.service"];
          before = ["cardano-wallet.service"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe cardano-wallet-fs;
          };
        };
        cardano-wallet = {
          after = ["cardano-node.service"];
          serviceConfig = {
            DynamicUser = lib.mkForce null;
            WorkingDirectory = walletHome;
            User = "cardano-node";
            Group = "cardano-node";
            TimeoutStartSec = "infinity";
            Restart = "always";
            RestartSec = 1;
          };
          postStart = ''
            while true; do
              if [ -S ${socketPath} ]; then
                current_perms=$(stat -c '%a' "${socketPath}" 2>/dev/null)
                if [ "$current_perms" != "660" ]; then
                  chmod 660 ${socketPath}
                  exit 0
                fi
              fi
              sleep 5
            done
          '';
        };
      };
    };
  };
}
