# in flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        # new! 👇
        nativeBuildInputs = with pkgs; [ gleam erlang rebar3 pkg-config ];
        # also new! 👇
        buildInputs = with pkgs; [
          openssl
          wayland
          wayland.dev
          zlib
          glib
          xorg.libX11
          libxkbcommon
          libxkbcommon.dev
        ];
      in with pkgs; {
        devShells.default = mkShell {
          # 👇 and now we can just inherit them
          inherit buildInputs nativeBuildInputs;
          LD_LIBRARY_PATH = lib.makeLibraryPath ([ # add some stuffs here
          ] ++ buildInputs ++ nativeBuildInputs);
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
          OPENSSL_DIR = "${pkgs.openssl.out}";
          OPENSSL_LIB_DIR = lib.makeLibraryPath [ pkgs.openssl ];
        };
      });
}
