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
  options = {
    cardano = {
      addresses = {
        enable = lib.mkEnableOption "Enable cardano-addresses" // {default = false;};
      };
    };
  };
  config = lib.mkIf (cfg.enable && cfg.addresses.enable) {
    environment = {
      systemPackages = [
        # pkgs.cardano-addresses
      ];
    };
    services = {
      cardano-addresses = {
        enable = false;
      };
    };
  };
}
