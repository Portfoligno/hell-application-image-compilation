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
          (packageSet.haskellPackages.callCabal2nix releasePackage ./. {}).overrideAttrs
            (_old: {
              allowSubstitutes = false;
              preferLocalBuild = true;
            });
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
        sdistCompiler =
          pkgs.haskellPackages.ghcWithPackages
            (packages:
              map
                (name: builtins.getAttr name packages)
                haskellDependencyNames);
        component = kind: name: drv: {
          inherit kind name;
          version = drv.version or "NOASSERTION";
          storePath = "${drv}";
        };
        ghcBootLibraryComponent = name: {
          kind = "ghc-boot-library";
          inherit name;
          version = "NOASSERTION";
          storePath = "${staticNativePackages.haskellPackages.ghc}";
        };
        haskellComponents = map
          (name:
            let
              drv = builtins.getAttr name staticNativePackages.haskellPackages;
            in
              if drv == null
              then ghcBootLibraryComponent name
              else component "direct-cabal-dependency" name drv)
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
            builder = pkgs.lib.getExe' app "hell";
            args = [
              "--compile"
              source
              "--output"
              (builtins.placeholder "out")
            ];
          };

        hellAutomationChecksSource =
          pkgs.replaceVars ./automation/hell-automation-checks.hell {
            cabal = pkgs.lib.getExe' pkgs.cabal-install "cabal";
            ghc = pkgs.lib.getExe' sdistCompiler "ghc";
            pandoc = pkgs.lib.getExe pkgs.pandoc;
          };
        hellAutomationChecks =
          mkHellImage
            "hell-automation-checks"
            hellAutomationChecksSource;
        documentationToolContract =
          builtins.derivation {
            inherit system;
            name = "hell-documentation-tool-contract-${system}";
            allowSubstitutes = false;
            preferLocalBuild = true;
            builder = hellAutomationChecks;
            args = [ "documentation-tool-contract" ];
            SOURCE_ROOT = ./.;
            PATH = "";
          };
        hellAutomationReleaseBuildSource =
          pkgs.replaceVars ./automation/hell-automation-release-build.hell {
            checkJsonschema = pkgs.lib.getExe pkgs.check-jsonschema;
            pyspdxtools =
              pkgs.lib.getExe'
                pkgs.python3Packages.spdx-tools
                "pyspdxtools";
          };
        hellAutomationReleaseBuild =
          mkHellImage
            "hell-automation-release-build"
            hellAutomationReleaseBuildSource;
        hellAutomationReleaseControlSource =
          pkgs.replaceVars ./automation/hell-automation-release-control.hell {
            releaseBuildImage = hellAutomationReleaseBuild;
            checkJsonschema = pkgs.lib.getExe pkgs.check-jsonschema;
            pyspdxtools =
              pkgs.lib.getExe'
                pkgs.python3Packages.spdx-tools
                "pyspdxtools";
          };
        hellAutomationReleaseControl =
          mkHellImage
            "hell-automation-release-control"
            hellAutomationReleaseControlSource;
        mkReleaseValidatorContract = name: image:
          builtins.derivation {
            inherit system;
            name = "hell-${name}-validator-contract-${system}";
            builder = image;
            args = [ "validator-contract" ];
          };
        releaseBuildValidatorContract =
          mkReleaseValidatorContract
            "release-build"
            hellAutomationReleaseBuild;
        releaseControlValidatorContract =
          mkReleaseValidatorContract
            "release-control"
            hellAutomationReleaseControl;
        hellAutomationDispatcherSource =
          pkgs.replaceVars ./automation/hell-automation.hell {
            checksImage = hellAutomationChecks;
            releaseBuildImage = hellAutomationReleaseBuild;
            releaseControlImage = hellAutomationReleaseControl;
          };
        hellAutomation =
          mkHellImage "hell-automation" hellAutomationDispatcherSource;
        hellAutomationTests =
          mkHellImage "hell-automation-tests" ./automation/hell-automation-tests.hell;

        staticHaskellCacheRoots =
          pkgs.lib.imap0
            (index: name:
              let
                dependency =
                  builtins.getAttr name staticNativePackages.haskellPackages;
              in {
                name = "haskell-${toString index}-${name}";
                path =
                  if dependency == null
                  then staticNativePackages.haskellPackages.ghc
                  else dependency;
              })
            haskellDependencyNames;
        staticCompilerCacheRoots = [
          {
            name = "toolchain-ghc";
            path = staticNativePackages.haskellPackages.ghc;
          }
        ];
        staticCRuntimeCacheRoots = [
          {
            name = "toolchain-cc";
            path = staticNativePackages.stdenv.cc;
          }
          {
            name = "toolchain-binutils";
            path = staticNativePackages.stdenv.cc.bintools;
          }
          {
            name = "toolchain-musl";
            path = staticNativePackages.stdenv.cc.libc;
          }
          {
            name = "toolchain-libffi";
            path = staticNativePackages.libffi;
          }
          {
            name = "toolchain-zlib";
            path = staticNativePackages.zlib;
          }
        ] ++ pkgs.lib.optional
          (staticNativePackages.gmp != null)
          {
            name = "toolchain-gmp";
            path = staticNativePackages.gmp;
          };
        staticToolchainCacheRoots =
          staticCompilerCacheRoots ++ staticCRuntimeCacheRoots;
        automationCacheRoots = [
          {
            name = "automation-dispatcher";
            path = hellAutomation;
          }
          {
            name = "automation-checks";
            path = hellAutomationChecks;
          }
          {
            name = "automation-release-build";
            path = hellAutomationReleaseBuild;
          }
          {
            name = "automation-release-control";
            path = hellAutomationReleaseControl;
          }
          {
            name = "automation-tests";
            path = hellAutomationTests;
          }
        ];
        staticHaskellCacheSeed =
          pkgs.linkFarm
            "hell-ci-cache-static-haskell-v1-${system}"
            staticHaskellCacheRoots;
        staticToolchainCacheSeed =
          pkgs.linkFarm
            "hell-ci-cache-static-toolchain-v1-${system}"
            staticToolchainCacheRoots;
        staticCompilerCacheSeed =
          pkgs.linkFarm
            "hell-ci-cache-static-compiler-v2-${system}"
            staticCompilerCacheRoots;
        staticCRuntimeCacheSeed =
          pkgs.linkFarm
            "hell-ci-cache-static-c-runtime-v2-${system}"
            staticCRuntimeCacheRoots;
        automationCacheSeed =
          pkgs.linkFarm
            "hell-ci-cache-automation-v2-${system}"
            automationCacheRoots;

        mkAutomationCheck = name: mode: image:
          builtins.derivation ({
            inherit system;
            name = "hell-${name}-${system}";
            allowSubstitutes = false;
            preferLocalBuild = true;
            builder = image;
            args = [ "nix-check" ];
            HELL_CHECK_MODE = mode;
            HELL_AUTOMATION_TESTS = hellAutomationTests;
            HELL_AUTOMATION = hellAutomation;
            HELL_TARGET_ARCH = releaseArch;
            SOURCE_ROOT = ./.;
            HELL_VERSIONS_FILE = ./release/versions.json;
            HELL_TOOL_FIND = pkgs.lib.getExe' pkgs.findutils "find";
            HELL_TOOL_GIT = pkgs.lib.getExe' pkgs.git "git";
            HELL_TOOL_STAT = pkgs.lib.getExe' pkgs.coreutils "stat";
            HELL_TOOL_CHMOD = pkgs.lib.getExe' pkgs.coreutils "chmod";
            PATH = pkgs.lib.makeBinPath [
              app
              pkgs.cabal-install
              pkgs.coreutils
              pkgs.git
              pkgs.gzip
              pkgs.gnutar
              pkgs.haskellPackages.hpack
              pkgs.pandoc
            ];
          } // pkgs.lib.optionalAttrs (mode == "hpack-drift") {
            HELL_TOOL_HPACK = pkgs.lib.getExe' pkgs.haskellPackages.hpack "hpack";
            HELL_TOOL_CP = pkgs.lib.getExe' pkgs.coreutils "cp";
          } // pkgs.lib.optionalAttrs (mode == "check-docs") {
            HELL_TOOL_CABAL = pkgs.lib.getExe' pkgs.cabal-install "cabal";
            HELL_TOOL_GHC = pkgs.lib.getExe' sdistCompiler "ghc";
            HELL_TOOL_PANDOC = pkgs.lib.getExe pkgs.pandoc;
          } // pkgs.lib.optionalAttrs (mode == "check-sdist") {
            HOME = "/homeless-shelter";
            HELL_TOOL_CABAL = pkgs.lib.getExe' pkgs.cabal-install "cabal";
            HELL_TOOL_GHC = pkgs.lib.getExe' sdistCompiler "ghc";
            HELL_TOOL_TIMEOUT = pkgs.lib.getExe' pkgs.coreutils "timeout";
            HELL_TOOL_TAR = pkgs.lib.getExe' pkgs.gnutar "tar";
          });
        automationAcceptance =
          builtins.derivation {
            inherit system;
            name = "hell-automation-acceptance-${system}";
            allowSubstitutes = false;
            preferLocalBuild = true;
            builder = hellAutomationChecks;
            args = [ "nix-acceptance" ];
            HELL_AUTOMATION_TESTS = hellAutomationTests;
            HELL_AUTOMATION = hellAutomation;
            HELL_AUTOMATION_RELEASE_BUILD_IMAGE = hellAutomationReleaseBuild;
            HELL_AUTOMATION_RELEASE_CONTROL_IMAGE = hellAutomationReleaseControl;
            HELL_PRODUCT_BINARY = pkgs.lib.getExe' app "hell";
            SOURCE_ROOT = ./.;
            HELL_TOOL_FIND = pkgs.lib.getExe' pkgs.findutils "find";
            HELL_TOOL_STAT = pkgs.lib.getExe' pkgs.coreutils "stat";
            PATH = pkgs.lib.makeBinPath [
              app
              pkgs.cabal-install
              pkgs.coreutils
              pkgs.git
              pkgs.gzip
              pkgs.gnutar
              pkgs.haskellPackages.hpack
              pkgs.pandoc
            ];
          };

        releaseStaticNative =
          builtins.derivation {
            inherit system;
            name = "${releasePackage}-${releaseVersion}-${releaseArch}-release";
            allowSubstitutes = false;
            preferLocalBuild = true;
            builder = hellAutomationReleaseBuild;
            args = [ "nix-release" ];
            HELL_STATIC_BINARY = pkgs.lib.getExe' staticNative "hell";
            HELL_TARGET_ARCH = releaseArch;
            SOURCE_ROOT = ./.;
            HELL_VERSIONS_FILE = ./release/versions.json;
            HELL_RELEASE_SCHEMA = ./release/release-manifest.schema.json;
            HELL_SPDX_SCHEMA = ./release/spdx-2.3.schema.json;
            SOURCE_REVISION = sourceRevision;
            SOURCE_DATE_EPOCH = sourceDateEpoch;
            TAR_MTIME = "@1";
            FLAKE_LOCK_SHA256 = lockSha256;
            NIX_SYSTEM = system;
            NIX_VERSION = builtins.nixVersion;
            GHC_VERSION = staticNativePackages.haskellPackages.ghc.version;
            COMPONENTS_JSON = componentsFile;
            FLAKE_INPUTS_JSON = flakeInputsFile;
            HELL_TOOL_FILE = pkgs.lib.getExe' pkgs.file "file";
            HELL_TOOL_READELF = pkgs.lib.getExe' pkgs.binutils "readelf";
            HELL_TOOL_CP = pkgs.lib.getExe' pkgs.coreutils "cp";
            HELL_TOOL_TRUNCATE = pkgs.lib.getExe' pkgs.coreutils "truncate";
            HELL_TOOL_TIMEOUT = pkgs.lib.getExe' pkgs.coreutils "timeout";
            HELL_TOOL_CHMOD = pkgs.lib.getExe' pkgs.coreutils "chmod";
            HELL_TOOL_INSTALL = pkgs.lib.getExe' pkgs.coreutils "install";
            HELL_TOOL_SHA1SUM = pkgs.lib.getExe' pkgs.coreutils "sha1sum";
            HELL_TOOL_SHA256SUM = pkgs.lib.getExe' pkgs.coreutils "sha256sum";
            HELL_TOOL_STAT = pkgs.lib.getExe' pkgs.coreutils "stat";
            HELL_TOOL_TAR = pkgs.lib.getExe' pkgs.gnutar "tar";
            HELL_TOOL_XZ = pkgs.lib.getExe' pkgs.xz "xz";
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
          automation-acceptance = automationAcceptance;
          automation =
            mkAutomationCheck "automation" "policy" hellAutomationChecks;
          metadata =
            mkAutomationCheck "metadata" "metadata" hellAutomationChecks;
          release-build-validator-contract = releaseBuildValidatorContract;
          release-control-validator-contract = releaseControlValidatorContract;
          documentation-tool-contract = documentationToolContract;
          hpack-drift =
            mkAutomationCheck "hpack-drift" "hpack-drift" hellAutomationChecks;
          documentation = documentationToolContract;
          source-distribution =
            mkAutomationCheck "source-distribution" "check-sdist" hellAutomationChecks;
          release-static-native = releaseStaticNative;
          build = pkgs.haskell.lib.doCheck app;
        };

        packages = {
          default = app;
          automation = hellAutomation;
          automation-checks = hellAutomationChecks;
          automation-release-build = hellAutomationReleaseBuild;
          automation-release-control = hellAutomationReleaseControl;
          automation-tests = hellAutomationTests;
          cache-client = pkgs.cachix;
          cache-seed-automation = automationCacheSeed;
          cache-seed-static-c-runtime = staticCRuntimeCacheSeed;
          cache-seed-static-compiler = staticCompilerCacheSeed;
          cache-seed-static-haskell = staticHaskellCacheSeed;
          cache-seed-static-toolchain = staticToolchainCacheSeed;
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
            program = pkgs.lib.getExe' app "hell";
          };
        };
      }
    );
}
