{ inputs, pkgs, commonPackages, shellHook, ... }:

pkgs.mkShell {
  inherit shellHook;
  name = "golang";
  packages = with pkgs; [
    go
    gopls
    go-task
  ] ++ commonPackages;
}
