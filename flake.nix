{
  description = "Hell 2026-05-29 with Application Image Compilation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        versions = builtins.fromJSON (builtins.readFile ./release/versions.json);
        releasePackage = versions.featureRelease.package;
        releaseVersion = versions.featureRelease.version;
        sourceRevision = self.rev or "dirty";
        sourceDateEpoch = toString (self.lastModified or 1);
        lockSha256 = builtins.hashFile "sha256" ./flake.lock;

        pkgs = import nixpkgs { inherit system; };
        pkgsStaticArm64 = import nixpkgs {
          localSystem = system;
          crossSystem = {
            config = "aarch64-unknown-linux-musl";
            isStatic = true;
          };
        };
        pkgsStaticAmd64 = import nixpkgs {
          localSystem = system;
          crossSystem = {
            config = "x86_64-unknown-linux-musl";
            isStatic = true;
          };
        };

        mkApp = packageSet:
          packageSet.haskellPackages.callCabal2nix releasePackage ./. {};
        app = mkApp pkgs;
        staticArm64 = mkApp pkgsStaticArm64;
        staticAmd64 = mkApp pkgsStaticAmd64;
        staticNativePackages =
          if system == "aarch64-linux" then pkgsStaticArm64 else pkgsStaticAmd64;
        staticNative =
          if system == "aarch64-linux" then staticArm64 else staticAmd64;
        releaseArch =
          if system == "aarch64-linux" then "aarch64" else "x86_64";

        haskellDependencyNames = [
          "QuickCheck"
          "aeson"
          "async"
          "base"
          "binary"
          "bytestring"
          "case-insensitive"
          "constraints"
          "containers"
          "criterion"
          "criterion-measurement"
          "directory"
          "filepath"
          "ghc-prim"
          "haskell-src-exts"
          "hspec"
          "http-types"
          "lucid2"
          "mtl"
          "optparse-applicative"
          "syb"
          "temporary"
          "template-haskell"
          "text"
          "th-lift"
          "th-orphans"
          "these"
          "time"
          "typed-process"
          "unix"
          "unliftio"
          "vector"
          "wai"
          "warp"
        ];
        component = kind: name: drv: {
          inherit kind name;
          version = drv.version or "NOASSERTION";
          storePath = "${drv}";
        };
        haskellComponents = map
          (name:
            component
              "direct-cabal-dependency"
              name
              (builtins.getAttr name staticNativePackages.haskellPackages))
          haskellDependencyNames;
        nativeComponents = [
          (component "linked-component" "musl" staticNativePackages.stdenv.cc.libc)
          (component "linked-component" "libffi" staticNativePackages.libffi)
          (component "linked-component" "zlib" staticNativePackages.zlib)
        ] ++ pkgs.lib.optional
          (staticNativePackages.gmp != null)
          (component "linked-component" "gmp" staticNativePackages.gmp);
        componentsFile =
          pkgs.writeText
            "hell-release-components.json"
            (builtins.toJSON (haskellComponents ++ nativeComponents));
        flakeInputsFile =
          pkgs.writeText
            "hell-release-flake-inputs.json"
            (builtins.toJSON (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes);

        mkHellImage = name: source:
          builtins.derivation {
            inherit system;
            name = "${name}-${system}";
            builder = "${app}/bin/hell";
            args = [
              "--compile"
              source
              "--output"
              (builtins.placeholder "out")
            ];
          };

        hellAutomation =
          mkHellImage "hell-automation" ./automation/hell-automation.hell;
        hellAutomationTests =
          mkHellImage "hell-automation-tests" ./automation/hell-automation-tests.hell;

        mkAutomationCheck = name: mode:
          builtins.derivation {
            inherit system;
            name = "hell-${name}-${system}";
            builder = hellAutomation;
            args = [ "nix-check" ];
            HELL_CHECK_MODE = mode;
            HELL_AUTOMATION_TESTS = hellAutomationTests;
            HELL_AUTOMATION = hellAutomation;
            HELL_PRODUCT_BINARY = "${app}/bin/hell";
            HELL_STATIC_BINARY = "${staticNative}/bin/hell";
            HELL_TARGET_ARCH = releaseArch;
            SOURCE_ROOT = ./.;
            HELL_VERSIONS_FILE = ./release/versions.json;
            HELL_TOOL_FIND = "${pkgs.findutils}/bin/find";
            HELL_TOOL_GIT = "${pkgs.git}/bin/git";
            HELL_TOOL_STAT = "${pkgs.coreutils}/bin/stat";
            HELL_TOOL_CHMOD = "${pkgs.coreutils}/bin/chmod";
            PATH = pkgs.lib.makeBinPath [
              app
              pkgs.cabal-install
              pkgs.coreutils
              pkgs.git
              pkgs.gnutar
              pkgs.haskellPackages.hpack
              pkgs.pandoc
            ];
          };

        releaseStaticNative =
          builtins.derivation {
            inherit system;
            name = "${releasePackage}-${releaseVersion}-${releaseArch}-release";
            builder = hellAutomation;
            args = [ "nix-release" ];
            HELL_STATIC_BINARY = "${staticNative}/bin/hell";
            HELL_TARGET_ARCH = releaseArch;
            SOURCE_ROOT = ./.;
            HELL_VERSIONS_FILE = ./release/versions.json;
            HELL_RELEASE_SCHEMA = ./release/release-manifest.schema.json;
            HELL_SPDX_SCHEMA = ./release/spdx-2.3.schema.json;
            SOURCE_REVISION = sourceRevision;
            SOURCE_DATE_EPOCH = sourceDateEpoch;
            TAR_MTIME_ARGUMENT = "--mtime=@${sourceDateEpoch}";
            FLAKE_LOCK_SHA256 = lockSha256;
            NIX_SYSTEM = system;
            NIX_VERSION = builtins.nixVersion;
            GHC_VERSION = staticNativePackages.haskellPackages.ghc.version;
            COMPONENTS_JSON = componentsFile;
            FLAKE_INPUTS_JSON = flakeInputsFile;
            HELL_TOOL_FILE = "${pkgs.file}/bin/file";
            HELL_TOOL_READELF = "${pkgs.binutils}/bin/readelf";
            HELL_TOOL_CP = "${pkgs.coreutils}/bin/cp";
            HELL_TOOL_TRUNCATE = "${pkgs.coreutils}/bin/truncate";
            HELL_TOOL_TIMEOUT = "${pkgs.coreutils}/bin/timeout";
            HELL_TOOL_CHMOD = "${pkgs.coreutils}/bin/chmod";
            HELL_TOOL_INSTALL = "${pkgs.coreutils}/bin/install";
            HELL_TOOL_SHA1SUM = "${pkgs.coreutils}/bin/sha1sum";
            HELL_TOOL_SHA256SUM = "${pkgs.coreutils}/bin/sha256sum";
            HELL_TOOL_STAT = "${pkgs.coreutils}/bin/stat";
            HELL_TOOL_TAR = "${pkgs.gnutar}/bin/tar";
            HELL_TOOL_XZ = "${pkgs.xz}/bin/xz";
          };
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
          automation = mkAutomationCheck "automation" "policy";
          metadata = mkAutomationCheck "metadata" "metadata";
          documentation = mkAutomationCheck "documentation" "check-docs";
          source-distribution = mkAutomationCheck "source-distribution" "check-sdist";
          release-static-native = releaseStaticNative;
          build = pkgs.haskell.lib.doCheck app;
        };

        packages = {
          default = app;
          automation = hellAutomation;
          automation-tests = hellAutomationTests;
          static-arm64 = staticArm64;
          static-amd64 = staticAmd64;
          static-native = staticNative;
          release-static-native = releaseStaticNative;
        };

        apps = {
          automation = {
            type = "app";
            program = "${hellAutomation}";
          };
          default = {
            type = "app";
            program = "${app}/bin/hell";
          };
        };
      }
    );
}
