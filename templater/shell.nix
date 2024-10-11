{ inputs, pkgs, commonPackages, shellHook, nuconfig, ... }:

let
  docs = pkgs.writeShellScriptBin "docs" ''
    echo "You have access to the following tools:"
    echo "  - new-template: A script to generate a new template."
    echo "  - kickstart: A tool that uses templates to generate projects."
  '';

  new-template = pkgs.writeShellScriptBin "new-template" ''
    OUT=$1
    
    if [ -z "$OUT" ]; then
      echo "Template name required."
      OUT="-h"
    fi

    if [ "-h" = "$OUT" ]; then
      echo "Create a new terraform module based on"
      echo "https://github.com/wscoble/dev-shells/tree/main/templates/infra"
      echo ""
      echo "Usage:"
      echo "  new-template <name>"
      exit 0
    fi

    if [ -d "./templates/$OUT" ]; then
      echo "Template $OUT already exists."
      exit 1
    fi

    cp -r ./templates/template ./templates/$OUT
  '';
in
pkgs.mkShell {
  inherit shellHook;
  name = "templater";
  packages = with pkgs; [
    kickstart
  ] ++ [
    docs
    new-template
  ] ++ commonPackages;
}
