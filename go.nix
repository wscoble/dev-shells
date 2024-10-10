{ inputs, pkgs, commonPackages, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    go
    gopls
    go-task
  ] ++ commonPackages;
}
