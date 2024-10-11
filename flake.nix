{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/63dacb46bf939521bdc93981b4cbb7ecb58427a0"; # latest 24.05
    systems.url = "github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e";
  };

  outputs = { self, nixpkgs, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            
            nuconfig = ./config.nu;

            shellHook = ''
              exec ${pkgs.nushell}/bin/nu --config ${nuconfig}
            '';

            commonPackages = with pkgs; [
              awscli2
              just
              yq
              jq
              syft
              grype
              nushell
              starship
              git
              gh
            ];
          in
          {
            templater = import ./templater/shell.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            terraform = import ./terraform/shell.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            nodejs = import ./nodejs/shell.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            golang = import ./golang/shell.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            kubernetes = import ./kubernetes/shell.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            default = pkgs.mkShell {
              name = "dev-shells";
              packages = commonPackages;
            };
          });
    
      apps = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            generate-script = pkgs.writeShellScriptBin "generate" ''
              # bash
              TPL=$1

              if [ -z "$TPL" ]; then
                echo "Template name required."
                TPL="-h"
              fi

              if [ "-h" = "$TPL" ]; then
                echo "Create a new terraform module based on"
                echo "https://github.com/wscoble/dev-shells/tree/main/templates/infra"
                echo ""
                echo "Usage:"
                echo "  generate <name>"
                exit 0
              fi
            '';
          in {
            generate = {
              type = "app";
              program = "${generate-script}/bin/generate";
            };
      });
    };
}
