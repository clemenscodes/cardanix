{inputs, ...}: final: prev: {
  cardano-db-sync = inputs.cardano-db-sync.packages.${prev.stdenv.hostPlatform.system}.default;
}
