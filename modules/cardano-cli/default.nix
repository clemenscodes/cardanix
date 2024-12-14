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
  inherit
    (inputs.cardano-wallet.packages.${pkgs.stdenv.hostPlatform.system})
    cardano-cli
    ;
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
