# Contributing

This repository accepts focused issues and pull requests for the independently
maintained Application Image Compilation feature line.

Use
[fork issues](https://github.com/Portfoligno/hell-application-image-compilation/issues)
for fork-specific defects and proposals. Report behavior belonging only to
the standard Hell build to
[chrisdone/hell](https://github.com/chrisdone/hell). Security reports must
follow [SECURITY.md](../SECURITY.md), not a public issue.

## Before opening a pull request

1. Explain the problem and keep the change focused.
2. Preserve Chris Done's original authorship and the unchanged
   BSD-3-Clause `LICENSE`.
3. Do not imply endorsement by Chris Done or upstream contributors.
4. Add or update tests for behavioral changes.
5. Run:

   ```shell
   nix build --no-update-lock-file
   nix flake check --no-update-lock-file
   ```

6. If documentation generated from Hell source changes, regenerate it with:

   ```shell
   nix build --no-update-lock-file .#automation --out-link result-automation
   ./result-automation generate-docs
   ```

7. Treat `package.yaml` as canonical package metadata. Regenerate
   `hell-application-image-compilation.cabal` with the repository-required
   hpack 0.38.3; do not hand-edit generated Cabal content.
8. Keep the upstream baseline and feature version separate. The current
   identity is
   `Hell 2026-05-29 — Application Image Compilation 1.0.0`.

Pull requests should describe the platforms exercised, including architecture
and static or dynamic linkage for Application Image Compilation changes.

No claim is made here about whether particular development tools were or were
not used. Contributors remain responsible for the accuracy, provenance,
licensing, security, and reviewability of everything they submit.
