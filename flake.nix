{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";
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
            
            nuconfig = pkgs.writeText "config.nu" ''
              $env.config = {
                show_banner: false,
              }
              $env.STARSHIP_SHELL = "nu"

              def create_left_prompt [] {
                  starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
              }

              # Use nushell functions to define your right and left prompt
              $env.PROMPT_COMMAND = { || create_left_prompt }
              $env.PROMPT_COMMAND_RIGHT = ""

              # The prompt indicators are environmental variables that represent
              # the state of the prompt
              $env.PROMPT_INDICATOR = ""
              $env.PROMPT_INDICATOR_VI_INSERT = ": "
              $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
              $env.PROMPT_MULTILINE_INDICATOR = "::: "
            '';

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
              # kickstart
              nodejs
            ];
          in
          {
            terraform = import ./terraform.nix { inherit inputs pkgs commonPackages shellHook nuconfig; };
            # go = import ./go.nix { inherit inputs pkgs commonPackages shellHook; };
            # kubernetes = import ./kubernetes.nix { inherit inputs pkgs; };
            # kubernetes = devenv.lib.mkShell {
            #   inherit inputs pkgs;
            #   modules = [
            #     {
            #       # https://devenv.sh/reference/options/
            #       packages = with pkgs; [
            #         k9s
            #         kubernetes-helm
            #         kubectl
            #         kubectl-gadget
            #         kubecolor
            #       ];
            #     }
            #   ];
            # };
            # nodejs = devenv.lib.mkShell {
            #   inherit inputs pkgs;
            #   modules =
            #     let
            #       yarn = pkgs.yarn.override { nodejs = pkgs.nodejs_20; };
            #     in [{
            #       # https://devenv.sh/reference/options/
            #       packages = with pkgs; [
            #         nodejs_20
            #       ] ++ [ yarn ];

            #       enterShell = ''
            #         export PATH=''$DEVENV_ROOT/node_modules/.bin:''$PATH
            #       '';
                # }];
            # };
          });
    };
}
