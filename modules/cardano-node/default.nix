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
  shelleyGenesisFile = builtins.fromJSON (builtins.readFile inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.environment}.nodeConfig.ShelleyGenesisFile);
  inherit (shelleyGenesisFile) networkMagic;
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
        pkgs.cardano-cli
        pkgs.cardano-submit-api
        pkgs.cardano-tracer
        pkgs.locli
        pkgs.db-analyser
        pkgs.bech32
      ];
      variables = {
        CARDANO_NODE_SOCKET_PATH = "${cfg.socketPath}";
        CARDANO_NODE_NETWORK_ID = "${networkMagic}";
        TESTNET_MAGIC = "${networkMagic}";
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
        cardano-node = {
          wantedBy = lib.mkForce [];
          serviceConfig = {
            TimeoutStartSec = "infinity";
          };
          postStart = ''
            while true; do
              if [ -S ${cfg.socketpath} ]; then
                chmod go+w ${cfg.socketPath}
                exit 0
              fi
              sleep 5
            done
          '';
        };
      };
    };
  };
}
