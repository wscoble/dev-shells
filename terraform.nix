{ inputs, pkgs, commonPackages, shellHook, nuconfig, ... }:

let
  nuenv = pkgs.writeText "env.nu" ''
  '';
in
pkgs.mkShell {
  inherit shellHook;

  packages = with pkgs; [
    opentofu
    tflint
    terrascan
    open-policy-agent
    driftctl
  ] ++ commonPackages;
}
