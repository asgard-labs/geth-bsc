{

  description = "A flake for BSC, Binance (BNB) Smart Chain, deployment in `Asgard Labs`";

  inputs = {

    flake-registry.url = github:asgard-labs/flake-registry;

    nixpkgs.follows = "flake-registry/nixpkgs";
    flake-utils.follows = "flake-registry/flake-utils";

    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-shell.inputs.nixpkgs.follows = "flake-registry/nixpkgs";

  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nixos-shell, ... }:
  let
    inherit (nixpkgs.lib) makeOverridable nixosSystem;
    mkSystem = configs: makeOverridable nixosSystem {
      system = "x86_64-linux";
      modules = configs ++ [ nixos-shell.nixosModules.nixos-shell ];
      };
  in {

      overlay = import ./overlay.nix;

      nixosConfigurations = {
        vm = mkSystem [
          ({ pkgs, ...}: {
              nixpkgs.overlays = [ self.overlay ];
              virtualisation.graphics = false;
              services.geth = {
                geth-bsc = {
                  enable = true;
                  websocket.apis = ["net" "eth" "txpool"];
                  syncmode = "snap";
                  package = pkgs.geth-bsc;
                };
              };
            })
          ];
        };

     }

     // flake-utils.lib.eachDefaultSystem (system:

     let
       pkgs = import nixpkgs {
         inherit system;
         overlays = [ self.overlay ];
       };
     in

     {

       apps = {
         geth-bsc = {
           type = "app";
           program = "${pkgs.geth-bsc}/bin/geth";
         };
         run-vm = {
           type = "app";
           program = "${self.packages.${system}.run-vm}/bin/run-vm";
         };
       };

       defaultApp = self.apps.${system}.run-vm;
       
       packages = rec {
         geth-bsc = pkgs.geth-bsc;
         nixos-shell = inputs.nixos-shell.packages.${system}.nixos-shell;
         run-vm = pkgs.writeScriptBin "run-vm" ''
           ${nixos-shell}/bin/nixos-shell --flake .#vm
         '';
       };
       
       defaultPackage = self.packages.${system}.openpbs;

       devShell = pkgs.mkShell {
         buildInputs = [
           pkgs.geth-bsc
           nixos-shell.defaultPackage."${system}"
           self.packages."${system}".run-vm
         ];
       };

     });

}
