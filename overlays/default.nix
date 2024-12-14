{inputs, ...}: let
  overlays = {
    bech32 = import ./bech32 {inherit inputs;};
    cardano-addresses = import ./cardano-addresses {inherit inputs;};
    cardano-node = import ./cardano-node {inherit inputs;};
    cardano-cli = import ./cardano-cli {inherit inputs;};
    cardano-wallet = import ./cardano-wallet {inherit inputs;};
    cardano-db-sync = import ./cardano-db-sync {inherit inputs;};
  };
in {
  default = builtins.attrValues overlays;
  inherit
    (overlays)
    bech32
    cardano-addresses
    cardano-node
    cardano-cli
    cardano-wallet
    cardano-db-sync
    ;
}
