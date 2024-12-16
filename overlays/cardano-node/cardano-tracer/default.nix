{inputs, ...}: final: prev: {
  cardano-tracer = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cardano-tracer-input-output-hk-cardano-node-10-1-3-36871ba;
}
