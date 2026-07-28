# Release operator policy

The only publishable release is produced by
`.github/workflows/release.yml` from the protected annotated tag recorded in
`versions.json`. Local and cross builds are release candidates only.

Repository owners must:

1. protect `main` and require `metadata`, `test (x86_64-linux)`, and
   `test (aarch64-linux)`;
2. protect `1.0.0_hell-2026-05-29` against unauthorized creation,
   update, and deletion;
3. enable immutable GitHub releases for every future publication; GitHub
   applies this setting prospectively and the already-published
   `1.0.0_hell-2026-05-29` release remains the sole explicit legacy mutable
   exception;
4. restrict allowed Actions to the full-SHA-pinned actions used by this
   repository; and
5. configure Pages for GitHub Actions at
   `https://portfoligno.github.io/hell-application-image-compilation/`.

The protected tag workflow validates the tag, builds and tests both native
Linux architectures, creates the exact six assets, attests them, and creates
or verifies a draft release. It accepts the exact annotated candidate tag only
when its peeled target equals the event commit and the target is linearly
comparable with the current `origin/main`; diverged or unrelated targets are
rejected. It never publishes the release.

Before publication, a maintainer merges the exact tagged commit into protected
`main` without moving the tag, waits for required checks, and confirms the tag
target is contained in `origin/main`. The maintainer then reviews the draft,
explicitly selects **Set as latest release**, and uses the Releases page
**Publish release** button. After publication, the maintainer confirms the
release displays GitHub's **Latest** badge. Publication starts a separate
read-only verification workflow that independently requires the tagged commit
to be contained in `origin/main`; it can also be dispatched from current
`main` to fix verification policy while checking the exact published tag. That
workflow may report a failure but cannot edit, delete, replace, or republish
anything.

The exact `1.0.0_hell-2026-05-29` release was published before release
immutability was enabled. Its repository metadata therefore records
`legacy-mutable`, requires the existing artifact provenance and SPDX
attestations, and does not claim a GitHub immutable-release attestation.
This is not a fallback for another release. Every future release must report
`isImmutable: true` and pass `gh release verify`.

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

The first release is bootstrapped from the locked Nix source closure; it cannot
download the release that it is in the process of creating.

## Bad-release recovery

Never move, delete for replacement, or reuse a release tag. Never replace an
asset under an existing filename. The legacy `1.0.0_hell-2026-05-29` record
must be preserved exactly; future immutable releases and their attestations
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
