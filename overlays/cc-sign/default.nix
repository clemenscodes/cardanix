{inputs, ...}: final: prev: {
  cc-sign = inputs.capkgs.packages.${prev.stdenv.hostPlatform.system}.cc-sign-IntersectMBO-credential-manager-0-1-2-0-081cc8c;
}
