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
  cardano-cli = inputs.capkgs.packages.${pkgs.stdenv.hostPlatform.system}.cardano-cli-input-output-hk-cardano-node-10-1-3-36871ba;
in {
  options = {
    cardano = {
      cli = {
        enable = lib.mkEnableOption "Enable cardano-cli" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment = {
      systemPackages = [cardano-cli];
    };
  };
}
