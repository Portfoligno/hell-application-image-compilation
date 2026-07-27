This is the first GitHub-only release of the independently maintained
Application Image Compilation feature line. It is based on upstream Hell
`2026-05-29`; it is not an upstream Hell release and does not imply upstream
endorsement.

## Added

- `hell --compile SCRIPT --output PROGRAM` emits executable application images
  on Linux; `-o` is the short output option.
- `--force` explicitly permits replacement of an existing output.
- The bounded, versioned application image format validates framing, checksum,
  target OS and architecture, compiler/runtime ABI, build identity, resource
  budgets, and the linked entry-point type.
- Native static x86_64-linux and aarch64-linux archives are built and executed
  natively, deterministically packaged, checksummed, described by SPDX 2.3
  SBOMs, and covered by GitHub artifact attestations.

## Limitations

- Emission is Linux-only and is not cross-compilation.
- An emitted image copies its runtime and inherits that runtime's architecture
  and static or dynamic linkage.
- Application images are executable programs, not native-code compilation,
  source protection, or a security sandbox.
- An emitted image cannot emit another image.
- Keep the `.hell` source as canonical and regenerate images when their source
  or runtime changes.

## Packaging and verification

The Cabal package is `hell-application-image-compilation` version `1.0.0`; the
executable remains `hell`. This release is not published to Hackage.

Verify downloaded assets with:

```text
sha256sum --check SHA256SUMS
gh attestation verify <archive> -R Portfoligno/hell-application-image-compilation
gh release verify 1.0.0_hell-2026-05-29 \
  -R Portfoligno/hell-application-image-compilation
```

Original Hell is Copyright (c) 2023 Chris Done and is distributed under the
BSD-3-Clause license.
