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
  environment = inputs.cardano-node.environments.${pkgs.stdenv.hostPlatform.system}.${cfg.node.environment};
  inherit (environment) nodeConfig submitApiConfig;
  shelleyGenesisFile = builtins.fromJSON (builtins.readFile nodeConfig.ShelleyGenesisFile);
  networkMagic = builtins.toString shelleyGenesisFile.networkMagic;
  inherit (inputs.cardano-node.packages.${pkgs.stdenv.hostPlatform.system}) cardano-submit-api;
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
        inherit (config.cardano.wallet) port listenAddress;
        inherit socketPath environment;
        network = cfg.node.environment;
        package = cardano-submit-api;
        config = submitApiConfig;
        script = pkgs.writeShellScript "cardano-submit-api" ''
          exec ${lib.getExe cfg.submit-api.package} \
            --socket-path "${cfg.submit-api.socketPath}" \
            --testnet-magic ${networkMagic} \
            --port ${toString cfg.submit-api.port} \
            --listen-address ${cfg.submit-api.listenAddress} \
            --config ${builtins.toFile "submit-api.json" (builtins.toJSON cfg.submit-api.config)}
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
