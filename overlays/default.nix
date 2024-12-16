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
    cardano-scripts = import ./cardano-scripts {inherit inputs system;};
    cardano-submit-api = import ./cardano-node/cardano-submit-api {inherit inputs;};
    cardano-tracer = import ./cardano-node/cardano-tracer {inherit inputs;};
    cardano-wallet = import ./cardano-wallet {inherit inputs;};
    daedalus = import ./daedalus {inherit inputs;};
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
    cardano-scripts
    cardano-submit-api
    cardano-tracer
    cardano-wallet
    ;
}
