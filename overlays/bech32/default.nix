{inputs, ...}: final: prev: {
  bech32-10-2-1 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.bech32-input-output-hk-cardano-node-10-2-1-52b708f;
  bech32-10-1-4 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.bech32-input-output-hk-cardano-node-10-1-4-1f63bf;
  bech32 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.bech32-input-output-hk-cardano-node-10-1-3-36871ba;
}
