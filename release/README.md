# Release operator policy

The only publishable release is produced by
`.github/workflows/release.yml` from the protected annotated tag recorded in
`versions.json`. Local and cross builds are release candidates only.

Before the first release, repository owners must:

1. protect `main` and require `metadata`, `test (x86_64-linux)`, and
   `test (aarch64-linux)`;
2. protect `application-image-compilation/v*` against unauthorized creation,
   update, and deletion;
3. enable immutable GitHub releases;
4. restrict allowed Actions to the full-SHA-pinned actions used by this
   repository; and
5. configure Pages for GitHub Actions at
   `https://portfoligno.github.io/hell-application-image-compilation/`.

The protected tag workflow validates the tag, builds and tests both native
Linux architectures, creates the exact six assets, attests them, and creates
or verifies a draft release. It never publishes the release. A maintainer
reviews the draft and uses the Releases page **Publish release** button.
Publication starts a separate read-only verification workflow; that workflow
may report a failure but cannot edit, delete, replace, or republish anything.

The consumer setup action is supported only after the first release has been
published, its architecture-specific archive and executable digests have been
reviewed into the action trust data, and read-only publication verification
has passed. The first release is bootstrapped from the locked Nix source
closure; it cannot download the release that it is in the process of creating.

## Bad-release recovery

Never move, delete for replacement, or reuse a release tag. Never replace an
asset under an existing filename. Immutable releases and their attestations
remain the audit record.

For an ordinary defect:

1. mark the bad release not-latest and add a prominent supersession notice;
2. prepare a corrected, monotonically newer feature release;
3. run every native, metadata, documentation, checksum, SBOM, and attestation
   gate again; and
4. publish the new immutable release and point users to it.

For a security defect, also publish a GitHub security advisory and follow
`SECURITY.md`. Delete an immutable release only for an exceptional legal or
active-harm requirement, and still never reuse its tag.

Rollback means selecting an older immutable release, verifying its
`SHA256SUMS`, artifact attestations, and release attestation, and reinstalling
that archive. Already-emitted application images retain their copied runtime;
installing or rolling back `hell` does not modify them. Regenerate images from
their canonical `.hell` source when changing runtime release.
