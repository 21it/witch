let nixpkgs = import ./nixpkgs.nix;
in
{
  pkgs ? import nixpkgs {
    overlays = import ./overlay.nix {
      inherit vimBackground vimColorScheme;
    };
  },
  usingDocker ? false,
  vimBackground ? "light",
  vimColorScheme ? "PaperColor",
}:
with pkgs;

let defaultShellHook = ''

      (cd /app/nix/ && cabal2nix ./.. > ./pkg.nix)
      (cd /app/ && gen-hie > ./hie.yaml)

    '';
    dockerShellHook = ''

      stack config set system-ghc --global true
      SKIP_GHC_CHECK="skip-ghc-check: true"
      grep -q "$SKIP_GHC_CHECK" ~/.stack/config.yaml \
        || echo "$SKIP_GHC_CHECK" >> ~/.stack/config.yaml

   '';
in

stdenv.mkDerivation {
  name = "haskell-shell";
  buildInputs = [
    haskell-ide
  ];
  TERM="xterm-256color";
  LC_ALL="C.UTF-8";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";
  NIX_SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
  shellHook =
    if usingDocker
    then dockerShellHook + defaultShellHook
    else defaultShellHook;
}
