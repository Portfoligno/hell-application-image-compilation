# Release operator policy

The only publishable release is produced by
`.github/workflows/release.yml` from the protected annotated tag recorded in
`versions.json`. Local and cross builds are release candidates only.

Before the first release, repository owners must:

1. protect `main` and require `metadata`, `test (x86_64-linux)`, and
   `test (aarch64-linux)`;
2. protect `1.0.0_hell-2026-05-29` against unauthorized creation,
   update, and deletion;
3. enable immutable GitHub releases;
4. restrict allowed Actions to the full-SHA-pinned actions used by this
   repository; and
5. configure Pages for GitHub Actions at
   `https://portfoligno.github.io/hell-application-image-compilation/`.

The protected tag workflow validates the tag, builds and tests both native
Linux architectures, creates the exact six assets, attests them, and creates
or verifies a draft release. It never publishes the release. A maintainer
reviews the draft, explicitly selects **Set as latest release**, and uses the
Releases page **Publish release** button. After publication, the maintainer
confirms the release displays GitHub's **Latest** badge. Publication starts a
separate read-only verification workflow; that workflow may report a failure
but cannot edit, delete, replace, or republish anything.

Release tags use `<AIC-SemVer>_hell-<Hell-YYYY-MM-DD>`. This is a composite
two-axis identifier, not SemVer, so release chronology and GitHub's latest
release must not be inferred by SemVer-ordering tags. The explicit latest
selection above is part of the operator gate, not a second approval gate. For
example, if Hell's next actual upstream version were hypothetically
`2026-06-12`:

- upstream-only: `1.0.0_hell-2026-06-12`;
- feature-only: `1.1.0_hell-2026-05-29`;
- combined: `1.1.0_hell-2026-06-12`.

The same Application Image Compilation version and Hell version always produce
the same tag. There is no revision or counter, and publication requires at
least one axis to advance. A correction on an unchanged Hell version therefore
bumps the feature patch version.

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
2. prepare a corrected release with a new tag, advancing the affected
   upstream and/or feature axis;
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
