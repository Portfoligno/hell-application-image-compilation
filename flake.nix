{
  description = "hell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pkgsStaticArm64 = import nixpkgs {
          localSystem  = system;
          crossSystem  = {
            config = "aarch64-unknown-linux-musl";
            isStatic = true;
          };
        };
        pkgsStaticAmd64 = import nixpkgs {
          localSystem  = system;
          crossSystem  = {
            config = "x86_64-unknown-linux-musl";
            isStatic = true;
          };
        };

        mkStaticApp = hp: hp.haskellPackages.callCabal2nix "hell" ./. {};

        app = pkgs.haskellPackages.callCabal2nix "hell" ./. {};
        staticArm64 = mkStaticApp pkgsStaticArm64;
        staticAmd64 = mkStaticApp pkgsStaticAmd64;
        staticNative =
          if system == "aarch64-linux"
          then staticArm64
          else staticAmd64;
      in {
        devShells.default = pkgs.haskellPackages.shellFor {
          name = "hell-dev";
          packages = _: [ app ];
          withHoogle = true;
          buildInputs = with pkgs.haskellPackages; [
            cabal-install
            haskell-language-server
            fourmolu
            hlint
            hpack
            pkgs.pandoc
            pkgs.zlib
          ];
        };
        checks = {
          run-script-check = pkgs.runCommand "test-hell-script" {
            buildInputs = [ app ];
          } ''
            hell ${./scripts/check.hell} --dir ${./examples} --dir ${./scripts}
            touch $out
          '';
          compiled-image-check = pkgs.runCommand "hell-compiled-image-check" {
            buildInputs = [ app ];
          } ''
            cat > program.hell <<'EOF'
            main = Text.putStrLn "compiled-image-ok"
            EOF
            hell --compile program.hell --output program
            ./program > actual
            grep -qx compiled-image-ok actual
            touch $out
          '';
          static-native-compiled-image-check = pkgs.runCommand "hell-static-native-compiled-image-check" {} ''
            cat > program.hell <<'EOF'
            main = Text.putStrLn "static-compiled-image-ok"
            EOF
            ${staticNative}/bin/hell --compile program.hell --output program
            ./program > actual
            grep -qx static-compiled-image-ok actual
            touch $out
          '';
          build = app;
        };
        packages = {
          default = app;
          static-arm64 = staticArm64;
          static-amd64 = staticAmd64;
        };
      }
    );
}
