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
  cliPkgs = import inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    overlays = [(import ../../overlays/cardano-cli {inherit inputs;})];
  };
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
      systemPackages = [
        cliPkgs.cardano-cli
      ];
    };
  };
}
