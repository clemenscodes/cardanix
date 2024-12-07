{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    cardano-addresses = {
      url = "github:IntersectMBO/cardano-addresses/3.12.0";
    };
    cardano-db-sync = {
      url = "github:IntersectMBO/cardano-db-sync/13.6.0.4";
    };
    cardano-node = {
      # master contains fix for custom state dirs
      # TODO: lock to 10.2.0 as soon as it is released
      url = "github:IntersectMBO/cardano-node/master";
    };
    cardano-wallet = {
      url = "github:cardano-foundation/cardano-wallet/v2024-11-18";
    };
    daedalus = {
      url = "github:input-output-hk/daedalus/6.0.2";
    };
  };

  outputs = {
    nixpkgs,
    cardano-addresses,
    cardano-db-sync,
    cardano-node,
    cardano-wallet,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    cardano-address-overlay = final: prev: {
      cardano-address = cardano-addresses.packages.${prev.stdenv.hostPlatform.system}."cardano-addresses-cli:exe:cardano-address";
    };
    cardano-db-sync-overlay = final: prev: {
      cardano-db-sync = cardano-db-sync.packages.${prev.stdenv.hostPlatform.system}.default;
    };
    cardano-node-overlay = final: prev: {
      inherit
        (inputs.cardano-wallet.packages.${pkgs.stdenv.hostPlatform.system})
        cardano-node
        cardano-cli
        cardano-address
        bech32
        ;
      inherit
        (cardano-node.legacyPackages.${prev.stdenv.hostPlatform.system})
        cardano-submit-api
        cardano-tracer
        locli
        db-analyser
        ;
    };
    overlays = [
      cardano-address-overlay
      cardano-db-sync-overlay
      cardano-node-overlay
      cardano-wallet.overlay
    ];
    pkgs = import nixpkgs {
      inherit system overlays;
    };
  in {
    overlays = {
      ${system} = overlays;
    };
    nixosModules = {
      ${system} = import ./modules {inherit inputs pkgs;};
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.cardano-node
            pkgs.cardano-wallet
          ];
        };
      };
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://clemenscodes.cachix.org"
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "clemenscodes.cachix.org-1:yEwW1YgttL2xdsyfFDz/vv8zZRhRGMeDQsKKmtV1N18="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
