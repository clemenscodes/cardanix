{inputs, ...}: final: prev: {
  cardano-node-10-2-1 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-node-input-output-hk-cardano-node-10-2-1-52b708f;
  cardano-node-10-1-4 = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-node-input-output-hk-cardano-node-10-1-4-1f63bf;
  cardano-node = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-node-input-output-hk-cardano-node-10-1-3-36871ba;
}
