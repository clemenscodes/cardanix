{
  inputs,
  pkgs,
  ...
}: {lib, ...}: {
  imports = [
    (import ./cardano-cli {inherit inputs pkgs;})
    (import ./cardano-node {inherit inputs pkgs;})
    (import ./cardano-wallet {inherit inputs pkgs;})
    (import ./daedalus {inherit inputs pkgs;})
  ];
  options = {
    cardano = {
      enable = lib.mkEnableOption "Enable Cardano development support" // {default = false;};
    };
  };
}
