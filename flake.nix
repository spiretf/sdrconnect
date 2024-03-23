{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-23.11";
    spire.url = "github:spiretf/nix";
    spire.inputs.nixpkgs.follows = "nixpkgs";
    spire.inputs.utils.follows = "utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    spire,
  }:
    utils.lib.eachSystem spire.systems (system: let
      overlays = [spire.overlays.default];
      pkgs = (import nixpkgs) {
        inherit system overlays;
      };
      inherit (pkgs) lib;
      spEnv = pkgs.sourcepawn.buildEnv (with pkgs.sourcepawn.includes; [sourcemod]);
    in rec {
      packages = rec {
        inherit spEnv;
        sdrconnect = pkgs.buildSourcePawnScript {
          name = "sdrconnect";
          src = ./plugin/sdrconnect.sp;
        };
        default = sdrconnect;
      };
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [spEnv];
      };
    });
}
