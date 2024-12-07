{inputs, ...}: final: prev: {
  daedalus = import ./daedalus.nix {
    inherit inputs;
    pkgs = prev;
  };
}
