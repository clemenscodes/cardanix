{inputs, ...}: final: prev: {
  cardano-address-v2025-01-09 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-address-cardano-foundation-cardano-wallet-v2025-01-09-6965d18;
  cardano-address = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-address-cardano-foundation-cardano-wallet-v2025-01-07-89faf17;
}
