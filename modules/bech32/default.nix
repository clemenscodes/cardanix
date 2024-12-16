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
  bech32 = inputs.capkgs.packages.${pkgs.stdenv.hostPlatform.system}.bech32-input-output-hk-cardano-node-10-1-3-36871ba;
in {
  options = {
    cardano = {
      bech32 = {
        enable = lib.mkEnableOption "Enable bech32" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.cli.enable) {
    environment = {
      systemPackages = [bech32];
    };
  };
}
