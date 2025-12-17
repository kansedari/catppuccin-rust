{
  description = "Soothing pastel theme for Rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    palette = {
      url = "github:kansedari/catppuccin-palette";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    palette,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    systems = lib.systems.flakeExposed;
  in
    flake-parts.lib.mkFlake {inherit self inputs;} {
      inherit systems;

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo
            clippy
            rustc
            rustfmt
            rust-analyzer
          ];
        };

        packages.default = let
          paletteJson = palette.packages.${system}.json;
        in
          pkgs.runCommand "catppuccin-rust-src" {} ''
            cp -r ${self} $out
            chmod -R +w $out
            cp ${paletteJson} $out/src/palette.json
          '';
      };
    };
}
