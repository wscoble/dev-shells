{ inputs, pkgs, commonPackages, shellHook, ... }:

let
  docs = pkgs.writeShellScriptBin "docs" ''
    echo "You have access to the following tools:"
    echo "  - tofu: A tool for generating Terraform configurations."
    echo "  - tflint: A linter for Terraform configurations."
    echo "  - terrascan: A tool for scanning Terraform configurations for security and compliance."
    echo "  - opa: A tool for policy management and enforcement."
    echo "  - driftctl: A tool for detecting drift in Terraform configurations."
    echo "  - init-tf-module: A script to initialize a new Terraform module."
  '';

  init-tf-module = pkgs.writeShellScriptBin "init-tf-module" ''
    OUT=$1
    if [ "-h" = "$OUT" ]; then
      echo "Create a new terraform module based on"
      echo "https://github.com/wscoble/dev-shells/tree/main/templates/infra"
      echo ""
      echo "Usage:"
      echo "  init-tf-module <directory|optional>"
      exit 0
    fi
    
    if [ -z "$OUT" ]; then
      OUT="infra"
    fi

    ${pkgs.kickstart}/bin/kickstart ${./templates/infra} -o $OUT
  '';
in
pkgs.mkShell {
  inherit shellHook;
  name = "terraform";
  packages = with pkgs; [
    opentofu
    tflint
    terrascan
    open-policy-agent
    driftctl
  ] ++ [
    docs
    init-tf-module
  ] ++ commonPackages;
}
