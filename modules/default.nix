{
  inputs,
  pkgs,
  ...
}: {lib, ...}: {
  imports = [
    (import ./cardano-addresses {inherit inputs pkgs;})
    (import ./cardano-db-sync {inherit inputs pkgs;})
    (import ./cardano-node {inherit inputs pkgs;})
    (import ./cardano-wallet {inherit inputs pkgs;})
    (import ./daedalus {inherit inputs pkgs;})
  ];
  options = {
    cardano = {
      enable = lib.mkEnableOption "Enable Cardano support" // {default = false;};
    };
  };
}
