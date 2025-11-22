{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-latest.url = "github:nixos/nix";
  };

  outputs = { self, nixpkgs, nix-latest }: let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    nix = nix-latest.packages.aarch64-darwin;
  in {
    devShells.aarch64-darwin.default = pkgs.mkShell {
      name = "igloo";
      nativeBuildInputs = [
        nix.nix-expr-c
        nix.nix-store-c
        nix.nix-util-c
      ];
    };
  };
}
