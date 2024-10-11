{ pkgs, shellHook, commonPackages, ... }:

pkgs.mkShell {
  inherit shellHook;
  name = "nodejs";
  packages = with pkgs; [
    nodejs_20
    bun
  ] ++ commonPackages;
}
