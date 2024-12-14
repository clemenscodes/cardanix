{inputs, ...}: final: pkgs: {
  daedalus = import ../../modules/daedalus/daedalus.nix {inherit inputs pkgs;};
}
