# Setup Hell bootstrap

This composite action installs exactly
`application-image-compilation/v1.0.0` for native Linux X64 and ARM64
runners. It has no caller-selectable version, URL, digest, member, or install
location.

## Pre-publication state

The action intentionally fails at its `Require reviewed published pins` step
until this directory contains all of:

- `trust/READY`
- `trust/linux-X64.archive.sha256`
- `trust/linux-X64.binary.sha256`
- `trust/linux-X64.json`
- `trust/linux-ARM64.archive.sha256`
- `trust/linux-ARM64.binary.sha256`
- `trust/linux-ARM64.json`

`READY` is not a trust root. It is an explicit availability marker added in
the same reviewed commit as the real trust files. No placeholder digest or
identity is accepted.

## Pinning sequence

1. Build and test the first release from the locked Nix source closure on
   native X64 and ARM64 runners.
2. Create and attest the exact six draft assets; do not publish them
   automatically.
3. Review the internal setup handoff against both native build artifacts and
   the draft.
4. Commit the two archive checksum files, two member checksum files, and two
   exact trust JSON files on protected `main`.
5. Add an empty, newline-terminated `trust/READY` in that same commit.
6. Publish with the GitHub Releases **Publish release** button.
7. Require the read-only published-release verifier to pass before advertising
   this action. Consumers pin the full commit containing the trust files.

The action revalidates cache hits. It caches only the immutable archive,
extracts only the reviewed `hell` member before executing it, verifies the
archive and member digests, installs mode `0755`, and delegates all subsequent
validation and output publication to Hell programs.

Callers must grant `contents: read` and `attestations: read`.
