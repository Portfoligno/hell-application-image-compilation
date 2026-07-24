# Changelog

This changelog covers the independently maintained Application Image
Compilation feature line. Upstream Hell history remains available from
[chrisdone/hell](https://github.com/chrisdone/hell).

## Application Image Compilation 1.0.0 — pending GitHub release

Runtime/release identity:
`Hell 2026-05-29 — Application Image Compilation 1.0.0`.

This is the first release prepared by
[Portfoligno/hell-application-image-compilation](https://github.com/Portfoligno/hell-application-image-compilation).
It is based on upstream Hell `2026-05-29`, is not an upstream release, and
does not imply upstream endorsement.

### Added

- `hell --compile SCRIPT --output PROGRAM`, with `-o` as the short output
  option, emits executable application images on Linux.
- `--force` provides explicit replacement of an existing output; without it,
  the existing destination is preserved.
- A bounded, versioned application image format encodes a pre-inferred program
  and validates its structure, checksum, target operating system and
  architecture, compiler/runtime ABI, build identity, and entry-point type.
- Dynamic and native-static Linux image execution checks are part of the Nix
  flake checks.

### Limitations

- Emission is Linux-only. The output inherits the emitting runtime's
  architecture and static or dynamic linkage and is not cross-compilation.
- Application images are not native machine code, source protection, or a
  security sandbox.
- An emitted image cannot emit another image.
- The `.hell` source remains canonical and must be retained.

### Packaging

- The Cabal package is `hell-application-image-compilation` version `1.0.0`;
  the executable remains `hell`.
- The first publication is GitHub-only, not Hackage.
- The `binary`, `filepath`, and `unix` dependencies support image encoding,
  executable-path handling, and atomic executable installation.

### License

Original Hell is Copyright (c) 2023 Chris Done and is distributed under the
BSD-3-Clause license. Binary archives and redistributed generated application
images must be accompanied by the `LICENSE` notice in documentation or other
materials. This fork does not imply upstream endorsement.
