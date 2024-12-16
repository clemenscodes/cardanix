# Cardanix

A NixOS module to glue together various Cardano components.

## Installation

### Overlay (Flakes)

After adding the overlay, you will have access to various components.

```nix
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    cardanix = {
      url = "github:clemenscodes/cardanix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    cardanix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];
      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [inputs.cardanix.overlays.default];
        };
      in {
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = [
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
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
```

### NixOS module (Flakes)

```nix
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    cardanix = {
      url = "github:clemenscodes/cardanix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    cardanix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];
      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        nixosModules = {
          default = {inputs, ...}: {
            imports = [inputs.cardanix.nixosModules.${system}];
            services = {
              cardano-node = {
                stateDirBase = "/mnt/ext4/crypto/cardano/"; # Can be anywhere
                runDirBase = "/mnt/ext4/crypto/cardano/"; # Can be anywhere
              };
            };
            cardano = {
              enable = true;
              bech32 = {
                enable = true;
              };
              address = {
                enable = true;
              };
              cli = {
                enable = true;
              };
              node = {
                enable = true;
                environment = "preview"; # mainnet by default
              };
              wallet = {
                enable = true;
              };
              db-sync = {
                enable = true;
              };
              daedalus = {
                enable = true;
                home = "$XDG_DATA_HOME/Daedalus";
              };
            };
          };
        };
      };
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = "true";
  };
}
```

This modules starts up the `cardano-node` and `cardano-wallet` in the desired environment.
Additional components can be enabled or disabled if desired.

Daedalus can be configured to use a custom directory for the blockchain
by setting the `cardano.daedalus.home` option.
