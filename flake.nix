{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    utils.url = "github:numtide/flake-utils";
    # rust-overlay.url = "github:oxalica/rust-overlay";
    my-utils = {
      url = "github:nmrshll/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, utils, my-utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # overlays = [ ];
        };

        # binaries = my-utils.binaries.${system} // { };

        baseInputs = with pkgs; [
          nodejs_22
          pnpm
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          pkgs.darwin.apple_sdk.frameworks.CoreServices
          pkgs.darwin.apple_sdk.frameworks.CoreFoundation
          pkgs.darwin.apple_sdk.frameworks.Foundation
          pkgs.libiconv
        ];

        devInputs = with pkgs; [
          nixpkgs-fmt
        ];

        env = {
          REPORT_GAS = true;
        };

        scripts = with pkgs; [
          (writeScriptBin "utest" ''npx hardhat test'')
          (writeScriptBin "hnode" ''npx hardhat node'')
          (writeScriptBin "deploy" ''npx hardhat ignition deploy ./ignition/modules/Lock.ts'')
        ];

      in
      {
        devShells.default = with pkgs; mkShell {
          inherit env;
          buildInputs = baseInputs ++ devInputs ++ scripts;
          shellHook = "
              # ${my-utils.binaries.${system}.configure-vscode};
              # dotenv
            ";
        };
      }
    );
}




