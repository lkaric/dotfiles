{
  description = "lkaric's macOS: nix-darwin + home-manager, multi-host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Herdr, pinned to a tag via flake.lock. It carries its own nixpkgs pin on
    # purpose (its Rust toolchain is tested against it); bump the tag below.
    herdr.url = "github:herdrdev/herdr/v0.8.2";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      mkHost =
        {
          name,
          system,
          user,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            host = {
              inherit name;
            };
          };
          modules = [
            ./modules/darwin
            ./hosts/${name}
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "bak";
                extraSpecialArgs = {
                  inherit inputs user;
                  host = {
                    inherit name;
                  };
                };
                users.${user.name} = import ./modules/home;
              };
            }
          ];
        };
    in
    {
      darwinConfigurations.hephaestus = mkHost {
        name = "hephaestus";
        system = "aarch64-darwin";
        user = {
          name = "lkaric";
          home = "/Users/lkaric";
          dotfiles = "/Users/lkaric/git/dotfiles";
        };
      };

      # `nix fmt` formats every .nix file in the tree (treefmt-based wrapper).
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
