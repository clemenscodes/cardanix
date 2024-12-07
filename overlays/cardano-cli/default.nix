{inputs, ...}: final: prev: {
  cardano-cli = inputs.cardano-cli.packages.${prev.stdenv.hostPlatform.system}."cardano-cli:exe:cardano-cli";
}
