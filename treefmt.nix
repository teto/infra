{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem = { pkgs, ... }: {
    treefmt = {
      # Used to find the project root
      projectRootFile = "flake.lock";

      programs.terraform.enable = true;

      settings.formatter = {
        nix = {
          command = "sh";
          options = [
            "-eucx"
            ''
              for i in "$@"; do
                ${pkgs.lib.getExe pkgs.statix} fix "$i"
              done

              ${pkgs.lib.getExe pkgs.nixpkgs-fmt} "$@"
            ''
            "--"
          ];
          includes = [ "*.nix" ];
          excludes = [
            "nix/sources.nix"
            # vendored from external source
            "build02/packages-with-update-script.nix"
          ];
        };

        python = {
          command = "sh";
          options = [
            "-eucx"
            ''
              ${pkgs.lib.getExe pkgs.ruff} --fix "$@"
              ${pkgs.lib.getExe pkgs.python3.pkgs.black} "$@"
            ''
            "--" # this argument is ignored by bash
          ];
          includes = [ "*.py" ];
        };
      };
    };
  };
}
