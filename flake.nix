{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
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
      url = "github:input-output-hk/daedalus/7.0.1";
    };
    capkgs = {
      url = "github:input-output-hk/capkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    overlays = import ./overlays {inherit inputs system;};
    pkgs = import nixpkgs {
      inherit system;
      overlays = [overlays.default];
    };
  in {
    inherit overlays;
    packages = {
      ${system} = {
        inherit
          (pkgs)
          bech32
          cardano-address
          cardano-cli
          cardano-db-sync
          cardano-node
          cardano-scripts
          cardano-submit-api
          cardano-wallet
          daedalus
          ;
      };
    };
    nixosModules = {
      ${system} = import ./modules {inherit inputs pkgs system;};
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bech32
            pkgs.cardano-address
            pkgs.cardano-cli
            # pkgs.cardano-db-sync
            # pkgs.cardano-node
            pkgs.cardano-scripts
            # pkgs.cardano-submit-api
            # pkgs.cardano-wallet
            # pkgs.daedalus
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
    experimental-features = ["nix-command" "flakes" "fetch-closure"];
  };
}
