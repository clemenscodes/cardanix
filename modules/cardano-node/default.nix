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
  socketPath = config.services.cardano-node.socketPath config.services.cardano-node.nodeId;
  shelleyGenesisFile = builtins.fromJSON (builtins.readFile inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment}.nodeConfig.ShelleyGenesisFile);
  networkMagic = builtins.toString shelleyGenesisFile.networkMagic;
  cardano-node-fs = pkgs.writeShellScriptBin "cardano-node-fs" ''
    if [ ! -d "${config.services.cardano-node.stateDir config.services.cardano-node.nodeId}" ]; then
      mkdir -p ${config.services.cardano-node.stateDir config.services.cardano-node.nodeId}
    fi

    current_owner=$(stat -c '%U:%G' "${config.services.cardano-node.stateDirBase}" 2>/dev/null)

    if [ "$current_owner" != "cardano-node:cardano-node" ]; then
      chown -R cardano-node:cardano-node ${config.services.cardano-node.stateDirBase}
    fi

    current_perms=$(stat -c '%a' "${config.services.cardano-node.stateDirBase}" 2>/dev/null)
    if [ "$current_perms" != "755" ]; then
        chmod -R 0755 ${config.services.cardano-node.stateDirBase}
    fi

    if [ -S ${socketPath} ]; then
      chmod 660 ${socketPath}
    fi
  '';
in {
  imports = ["${inputs.cardano-node}/nix/nixos"];
  options = {
    cardano = {
      node = {
        enable = lib.mkEnableOption "Enable cardano-node" // {default = false;};
        environment = lib.mkOption {
          type = lib.types.enum ["mainnet" "preprod" "preview" "sanchonet"];
          default = "mainnet";
        };
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.node.enable) {
    environment = {
      systemPackages = [
        pkgs.cardano-node
      ];
      variables = {
        CARDANO_NODE_SOCKET_PATH = socketPath;
        CARDANO_NODE_NETWORK_ID = networkMagic;
        TESTNET_MAGIC = networkMagic;
      };
    };
    services = {
      cardano-node = {
        inherit (cfg.node) enable environment;
        hostAddr = "0.0.0.0";
        useNewTopology = true;
      };
      cardano-submit-api = {
        enable = false;
      };
    };
    systemd = {
      services = {
        cardano-node-fs = {
          after = ["local-fs.target"];
          before = ["cardano-node.service"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe cardano-node-fs;
          };
        };
        cardano-node = {
          serviceConfig = {
            TimeoutStartSec = "infinity";
          };
          postStart = ''
            while true; do
              if [ -S ${socketPath} ]; then
                current_perms=$(stat -c '%a' "${socketPath}" 2>/dev/null)
                if [ "$current_perms" != "755" ]; then
                  chmod 660 ${socketPath}
                  exit 0
                fi
                if [ "$current_perms" != "660" ]; then
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
