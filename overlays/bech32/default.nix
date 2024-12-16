{inputs, ...}: final: prev: {
  bech32 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.bech32-input-output-hk-cardano-node-10-1-3-36871ba;
}
