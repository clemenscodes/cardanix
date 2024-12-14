{
  inputs,
  system,
  ...
}: {
  config,
  lib,
  ...
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [inputs.cardano-wallet.overlay];
  };
  cfg = config.cardano;
  walletCfg = config.services.cardano-wallet;
  inherit (config.services) cardano-node;
  inherit (cardano-node) stateDirBase;
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
    if [ "$current_perms" != "775" ]; then
      chmod -R 0775 ${stateDirBase}${config.services.cardano-wallet.database}
    fi

    current_owner=$(stat -c '%U:%G' "${walletHome}" 2>/dev/null)

    if [ "$current_owner" != "cardano-node:cardano-node" ]; then
      chown -R cardano-node:cardano-node ${walletHome}
    fi

    current_perms=$(stat -c '%a' "${walletHome}" 2>/dev/null)
    if [ "$current_perms" != "775" ]; then
      chmod -R 0775 ${walletHome}
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
        WALLET_STATE_DIRECTORY = walletHome;
      };
    };
    services = {
      cardano-wallet = {
        enable = lib.mkForce false;
        serverArgs = lib.concatStringsSep " " (
          # Only specify arguments if they have different value than the default:
          lib.optionals (walletCfg.listenAddress != "127.0.0.1") [
            "--listen-address"
            (lib.escapeShellArg walletCfg.listenAddress)
          ]
          ++ lib.optionals (walletCfg.port != 8090) [
            "--port"
            (toString walletCfg.port)
          ]
          ++ lib.optionals (walletCfg.logLevel != "DEBUG") [
            "--log-level"
            walletCfg.logLevel
          ]
          ++ lib.optionals (walletCfg.syncTolerance != 300) [
            "--sync-tolerance"
            "${toString walletCfg.syncTolerance}s"
          ]
          ++ [
            "--node-socket"
            walletCfg.nodeSocket
            "--pool-metadata-fetching"
            (
              if (walletCfg.poolMetadataFetching.enable)
              then
                (
                  if walletCfg.poolMetadataFetching.smashUrl != null
                  then walletCfg.poolMetadataFetching.smashUrl
                  else "direct"
                )
              else "none"
            )
            "--${walletCfg.walletMode}"
          ]
          ++ lib.optional (walletCfg.walletMode != "mainnet")
          (lib.escapeShellArg walletCfg.genesisFile)
          ++ lib.optionals (walletCfg.tokenMetadataServer != null)
          ["--token-metadata-server" walletCfg.tokenMetadataServer]
          ++ lib.optionals (walletCfg.database != null)
          ["--database" walletHome]
          ++ lib.mapAttrsToList
          (name: level: "--trace-${name}=${level}")
          walletCfg.trace
        );
        command = lib.concatStringsSep " " ([
            (lib.getExe walletCfg.package)
            "serve"
            walletCfg.serverArgs
          ]
          ++ lib.optionals (walletCfg.rtsOpts != "") ["+RTS" walletCfg.rtsOpts "-RTS"]);
        package = pkgs.cardano-wallet;
        nodeSocket = socketPath;
        listenAddress = "0.0.0.0";
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
          description = "cardano-wallet daemon";
          after = ["cardano-node.service" "cardano-wallet-fs.service"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            User = "cardano-node";
            Group = "cardano-node";
            TimeoutStartSec = "infinity";
            RestartSec = 1;
            WorkingDirectory = walletHome;
            ExecStart = config.services.cardano-wallet.command;
            StateDirectory = lib.removePrefix "${stateDirBase}${config.services.cardano-wallet.database}/" walletHome;
          };
        };
      };
    };

    assertions = [
      {
        assertion = (walletCfg.walletMode == "mainnet") == (walletCfg.genesisFile == null);
        message = ''          The option services.cardano-wallet.genesisFile must be set
                  if, and only if, services.cardano-wallet.walletMode is not \"mainnet\".
        '';
      }
    ];
  };
}
