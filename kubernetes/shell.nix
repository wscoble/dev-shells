{ pkgs, shellHook, commonPackages, ...}:

pkgs.mkShell {
  inherit shellHook;
  name = "kubernetes";
  packages = with pkgs; [
    k9s
    kubernetes-helm
    kubectl
    kubectl-gadget
    kubecolor
  ] ++ commonPackages;
}