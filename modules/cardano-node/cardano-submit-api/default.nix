{
  inputs,
  pkgs,
  ...
}: {
  config,
  lib,
  ...
}: let
  cfg = config.cardano.node;
  socketPath = config.services.cardano-node.socketPath config.services.cardano-node.nodeId;
  environment = inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.environment};
  inherit (environment) nodeConfig submitApiConfig;
  shelleyGenesisFile = builtins.fromJSON (builtins.readFile nodeConfig.ShelleyGenesisFile);
  networkMagic = builtins.toString shelleyGenesisFile.networkMagic;
  cardano-submit-api = inputs.capkgs.packages.${pkgs.stdenv.hostPlatform.system}.cardano-submit-api-input-output-hk-cardano-node-10-1-3-36871ba;
in {
  imports = ["${inputs.cardano-node}/nix/nixos"];
  options = {
    cardano = {
      node = {
        submit-api = {
          enable = lib.mkEnableOption "Enable cardano-submit-api" // {default = false;};
        };
      };
    };
  };
  config = lib.mkIf (config.cardano.enable && cfg.enable && cfg.submit-api.enable) {
    environment = {
      systemPackages = [cardano-submit-api];
    };
    services = {
      cardano-submit-api = {
        enable = false;
        inherit socketPath environment;
        listenAddress = config.services.cardano-node.hostAddr;
        port = config.services.cardano-node.port + 1;
        network = cfg.environment;
        package = cardano-submit-api;
        config = submitApiConfig;
        script = pkgs.writeShellScript "cardano-submit-api" ''
          exec ${lib.getExe config.services.cardano-submit-api.package} \
            --socket-path "${config.services.cardano-submit-api.socketPath}" \
            --testnet-magic ${networkMagic} \
            --port ${toString config.services.cardano-submit-api.port} \
            --listen-address ${config.services.cardano-submit-api.listenAddress} \
            --config ${builtins.toFile "submit-api.json" (builtins.toJSON config.services.cardano-submit-api.config)}
        '';
      };
    };
    systemd = {
      services = {
        cardano-submit-api = {
          after = ["cardano-node.service"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            User = "cardano-node";
            Group = "cardano-node";
            TimeoutStartSec = "infinity";
            RestartSec = 1;
            ExecStart = config.services.cardano-submit-api.script;
          };
        };
      };
    };
  };
}
