{
  description = "A self-explaining git tutorial";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      # Use the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      gitignore,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          f pkgs
        );
      treefmtEval = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      inherit (gitignore.lib) gitignoreSource;
    in
    {
      # for `nix fmt`
      formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = forAllSystems (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;

        markdownlint =
          pkgs.runCommand "mdl"
            {
              buildInputs = [ pkgs.mdl ];
            }
            ''
              mkdir $out
              mdl ${gitignoreSource ./.}/**/*.md
            '';

        # shellcheck =
        #   pkgs.runCommand "shellcheck"
        #     {
        #       buildInputs = [ pkgs.shellcheck ];
        #     }
        #     ''
        #       mkdir $out
        #       cp -r ${gitignoreSource ./.} $out
        #       cd $out
        #       shellcheck -x *.sh **/*.sh

        #       # FIXME: figure out how to check the built files
        #       # ./build.sh -v -v
        #       # shellcheck tutorial/.git/redeem.nuggit tutorial/.git/nuggit-src/hooks/* tutorial/.git/*.sh
        #     '';

        ## FIXME: make build work with repeated file edits
        ##        nix makes all files readonly, so repeated editing of our build
        ##        script fails miserably
        # test =
        #   pkgs.runCommand "test_suite"
        #     {
        #       buildInputs = [ pkgs.git ];
        #     }
        #     ''
        #       export TEST_DIR=$(mktemp -d)
        #       cp -r ${gitignoreSource ./.}/* "$TEST_DIR"
        #       cd "$TEST_DIR"
        #       ./test.sh -v -v
        #     '';

      });
    };
}
