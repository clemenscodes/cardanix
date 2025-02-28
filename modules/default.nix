{
  inputs,
  pkgs,
  system,
  ...
}: {lib, ...}: {
  imports = [
    (import ./bech32 {inherit inputs pkgs;})
    (import ./cardano-addresses {inherit inputs pkgs;})
    (import ./cardano-cli {inherit inputs pkgs;})
    (import ./cardano-db-sync {inherit inputs pkgs;})
    (import ./cardano-node {inherit inputs pkgs;})
    (import ./cardano-wallet {inherit inputs pkgs system;})
    (import ./daedalus {inherit inputs pkgs;})
  ];
  options = {
    cardano = {
      enable = lib.mkEnableOption "Enable Cardano support" // {default = false;};
    };
  };
}
