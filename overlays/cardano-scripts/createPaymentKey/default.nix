{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "create-payment-key" ''
  PUBLIC_KEY="payment.vkey"
  PRIVATE_KEY="payment.skey"
  echo "Creating payment key with verification key $PUBLIC_KEY and signing key $PRIVATE_KEY"
  ${lib.getExe pkgs.cardano-cli} \
    latest \
    address \
    key-gen \
    --verification-key-file $PUBLIC_KEY \
    --signing-key-file $PRIVATE_KEY
''
