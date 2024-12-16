{inputs, ...}: final: prev: {
  cardano-node = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-node-input-output-hk-cardano-node-10-1-3-36871ba;
}
