{inputs, ...}: final: prev: {
  cardano-cli = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-cli-input-output-hk-cardano-node-10-1-3-36871ba;
}
