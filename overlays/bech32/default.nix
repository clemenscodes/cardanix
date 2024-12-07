{inputs, ...}: final: prev: {
  bech32 = inputs.bech32.packages.${prev.stdenv.hostPlatform.system}."bech32:exe:bech32";
}
