{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    cardano-addresses = {
      url = "github:IntersectMBO/cardano-addresses";
    };
    cardano-db-sync = {
      url = "github:IntersectMBO/cardano-db-sync";
    };
    # cardano-node = {
    #   url = "github:IntersectMBO/cardano-node/10.1.3";
    # };
    cardano-node = {
      url = "github:clemenscodes/cardano-node/feature/custom-state-dir";
    };
    cardano-wallet = {
      url = "github:cardano-foundation/cardano-wallet";
    };
    daedalus = {
      url = "github:input-output-hk/daedalus";
    };
  };

  outputs = {
    nixpkgs,
    flake-parts,
    cardano-addresses,
    cardano-db-sync,
    cardano-node,
    cardano-wallet,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          cardano-address = cardano-addresses.packages.${system}."cardano-addresses-cli:exe:cardano-address";
        })
        (final: prev: {
          cardano-db-sync = cardano-db-sync.packages.${system}.default;
        })
        (final: prev: {
          inherit
            (cardano-node.legacyPackages.${system})
            cardano-node
            cardano-cli
            cardano-submit-api
            cardano-tracer
            locli
            db-analyser
            bech32
            ;
        })
        cardano-wallet.overlay
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [system];
      flake = {
        nixosModules = {
          ${system} = import ./modules {inherit inputs pkgs;};
        };
      };
      perSystem = {...}: {
        formatter = pkgs.alejandra;
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
