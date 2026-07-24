# Support

## Supported project

This repository supports only the independently maintained Application Image
Compilation feature line. Questions about the standard Hell build or upstream
behavior should go to [chrisdone/hell](https://github.com/chrisdone/hell).

This fork is not endorsed by Chris Done or upstream contributors.

## Current support boundary

Application Image Compilation 1.0.0 is experimental until every gate in
[RELEASE.md](RELEASE.md) passes. Until then, no build is a supported release.
After publication, support is best-effort and limited to the latest GitHub
release.

The intended release boundary is:

- Linux application image emission and execution;
- the architectures for which that release publishes and verifies an
  artifact;
- both static and dynamically linked runtimes when the corresponding build is
  covered by the release gates; and
- application images created by the exact compatible runtime/ABI identified
  by that release.

The following are outside the support boundary:

- macOS, Windows, and other non-Linux image emission;
- cross-compilation or moving an image to another operating system,
  architecture, compiler/runtime ABI, or incompatible Hell release;
- native machine-code generation or source protection;
- sandboxing untrusted Hell programs or application images;
- application images that emit further application images;
- old releases after a newer release is published;
- Stack configurations not covered by the release gates; and
- third-party repackaging that changes the executable or omits required
  license materials.

Generated executables use the GHC runtime. Its reserved `+RTS ... -RTS`
argument syntax may be interpreted before the embedded Hell program receives
arguments.

## Asking for help

Open a
[GitHub issue](https://github.com/Portfoligno/hell-application-image-compilation/issues)
with:

- the release tag and complete `hell --version` output;
- operating system and architecture;
- whether the runtime is static or dynamically linked;
- the command used and a minimal `.hell` reproduction;
- expected and actual behavior; and
- whether the problem occurs during `--compile` or while running the emitted
  image.

For suspected vulnerabilities, do not use a public issue. Follow
[SECURITY.md](SECURITY.md).
