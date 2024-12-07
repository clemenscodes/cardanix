{inputs, ...}: final: prev: {
  cardano-address = inputs.cardano-addresses.packages.${prev.stdenv.hostPlatform.system}."cardano-addresses-cli:exe:cardano-address";
}
