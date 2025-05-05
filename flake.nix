{
  description = "A very basic flake";

  inputs = {
    specter-nixpkgs.url = "git+ssh://git@github.com/Specter-Co/specter-nixpkgs?ref=master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, specter-nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = specter-nixpkgs.legacyPackages.${system};
        in {
          devShells.default = import ./shell.nix {
            inherit system pkgs;
            # If you would like to use menuconfig or xconfig to configure your image,
            # then comment out one of the following lines.
            #
            # By default, we do not want to pull in the dependencies these require.

            # menuconfig = true;
            # xconfig = true;
          };
        }
      );
}

