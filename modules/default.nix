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
      enable = lib.mkEnableOption "Enable Cardano support" // {default = false;};
    };
    networking = {
      firewall = {
        enable = true;
        allowedTCPPorts = [443 3001];
        allowedUDPPortRanges = [
          {
            from = 30000;
            to = 60000;
          }
        ];
      };
    };
  };
}
