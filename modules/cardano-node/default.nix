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
        port = lib.mkOption {
          type = lib.types.either lib.types.int lib.types.str;
          default = 3001;
          description = ''
            The port number
          '';
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
    };
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [cfg.node.port];
      };
    };
    services = {
      cardano-node = {
        inherit (cfg.node) enable port;
        instances = 1;
        hostAddr = "0.0.0.0";
        environment = "preview";
        dbPrefix = "db";
        socketGroup = "cardano-node";
        # stateDirBase = "/mnt/ext4/crypto/cardano/";
        # runDirBase = "/mnt/ext4/crypto/cardano/";
        # profiling = "none";
        # eventlog = false;
        # asserts = false;
        # isProducer = false;
        # signingKey = null;
        # delegationCertificate = null;
        # kesKey = null;
        # vrfKey = null;
        # operationalCertificate = null;
        # systemdSocketActivation = false;
        # extraServiceConfig = _: {};
        # extraSocketConfig = _: {};
        # nodeId = 0;
        # publicProducers = [];
        # instancePublicProducers = _: [];
        # producers = [];
        # instanceProducers = _: [];
        # useNewTopology = false;
        # useLegacyTracing = true;
        # usePeersFromLedgerAfterSlot = null;
        # bootstrapPeers = null;
        # topology = null;
        # useSystemdReload = false;
        # extraNodeConfig = {};
        # extraNodeInstanceConfig = _: {};
        # nodeConfigFile = null;
        # forceHardForks = {};
        # withCardanoTracer = false;
        # withUtxoHdLmdb = false;
        # extraArgs = [];
      };
      cardano-submit-api = {
        enable = false;
      };
    };
  };
}
