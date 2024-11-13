{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    cardano-node = {
      url = "github:IntersectMBO/cardano-node";
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
    cardano-node,
    cardano-wallet,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      overlays = [
        cardano-node.overlay
        cardano-wallet.overlay
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [system];
      flake = {
        nixosModules = {
          default = import ./modules {inherit inputs pkgs;};
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
