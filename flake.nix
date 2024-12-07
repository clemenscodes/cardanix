{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    bech32 = {
      url = "github:IntersectMBO/bech32/v1.1.7";
    };
    cardano-addresses = {
      url = "github:IntersectMBO/cardano-addresses";
    };
    cardano-db-sync = {
      url = "github:IntersectMBO/cardano-db-sync/13.6.0.4";
    };
    cardano-node = {
      # master contains fix for custom state dirs
      # TODO: lock to 10.2.0 as soon as it is released
      url = "github:IntersectMBO/cardano-node/master";
    };
    cardano-cli = {
      url = "github:IntersectMBO/cardano-cli/cardano-cli-10.1.1.0";
    };
    cardano-wallet = {
      url = "github:cardano-foundation/cardano-wallet/v2024-11-18";
    };
    daedalus = {
      url = "github:input-output-hk/daedalus/6.0.2";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    overlays = import ./overlays {inherit inputs;};
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
            pkgs.bech32
            pkgs.cardano-address
            pkgs.cardano-node
            pkgs.cardano-cli
            pkgs.cardano-wallet
            pkgs.cardano-db-sync
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
