{inputs, ...}: final: prev: {
  cardano-address = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-address-cardano-foundation-cardano-wallet-v2024-11-18-9eb5f59;
}
