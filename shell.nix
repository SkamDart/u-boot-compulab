{ pkgs ? import <nixpkgs> {}
, target ? "aarch64-multiplatform"
, system
# Optionally add dependencies for xconfig and menu config 
, menuconfig ? false
, xconfig ? false
}:
let
  # If we are aarch64-linux, then we do not need a cross-toolchain.
  # Otherwise, grab the pkgsCross
  #
  # Notes on cross-compilation
  # https://nixos.wiki/wiki/Cross_Compiling#Lazy_cross-compiling
  # https://matthewbauer.us/blog/beginners-guide-to-cross.html
  shouldCross = system == "aarch64-linux";
  pkgsCross =
    if shouldCross
    then builtins.trace "using native pkgs" pkgs
    else builtins.trace "using pkgsCross" pkgs.pkgsCross.${target};
  # Even if we are cross-compiling we still want the pkg-config and friends for the machine we are building on, not building for.
  pkgsBuild = pkgsCross.buildPackages;
  menuconfigAttrs = if menuconfig then [ pkgsBuild.pkg-config pkgsBuild.ncurses ] else [];
  xconfigAttrs = if xconfig then [ pkgsBuild.pkg-config pkgsBuild.qt5.qtbase ] else [];
  # We want to use the same build environment that our nix derivation uses but with some new friends.
  #
  # This is why we choose to use overrideAttrs
  # https://ryantm.github.io/nixpkgs/using/overrides/#sec-pkg-overrideAttrs
  drv = pkgsCross.ubootNanoPCT4.overrideAttrs(final: prev: {
    # give it a new name so we can differentiate between nix build derivations and nix shell roots
    pname = "compulab-u-boot";
    nativeBuildInputs = builtins.concatLists [
      # our build tools for
      prev.nativeBuildInputs
      # add our optional inputs
      menuconfigAttrs
      xconfigAttrs
      [ pkgsBuild.ripgrep ]
    ];
    shellHook = ''
    export MACHINE='ucm-imx8m-plus'
    '';
  });
in
drv
