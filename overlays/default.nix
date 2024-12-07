{inputs, ...}: [
  (import ./bech32 {inherit inputs;})
  (import ./cardano-addresses {inherit inputs;})
  (import ./cardano-node {inherit inputs;})
  (import ./cardano-cli {inherit inputs;})
  (import ./cardano-wallet {inherit inputs;})
  (import ./cardano-db-sync {inherit inputs;})
]
