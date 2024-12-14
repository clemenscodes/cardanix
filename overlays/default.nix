{
  inputs,
  system,
  ...
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
  };
  overlays = {
    bech32 = import ./bech32 {inherit inputs;};
    cardano-addresses = import ./cardano-addresses {inherit inputs;};
    cardano-cli = import ./cardano-cli {inherit inputs;};
    cardano-db-sync = import ./cardano-db-sync {inherit inputs;};
    cardano-node = import ./cardano-node {inherit inputs;};
    cardano-submit-api = import ./cardano-submit-api {inherit inputs;};
    cardano-wallet = import ./cardano-wallet {inherit inputs;};
  };
in {
  default = pkgs.lib.composeManyExtensions (builtins.attrValues overlays);
  inherit
    (overlays)
    bech32
    cardano-addresses
    cardano-cli
    cardano-db-sync
    cardano-node
    cardano-submit-api
    cardano-wallet
    ;
}
