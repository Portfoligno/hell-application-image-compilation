# Release contract

The first publication is a GitHub-only release. Do not publish this package to
Hackage as part of the 1.0.0 release.

## Fixed identity

- Runtime and release wording:
  `Hell 2026-05-29 — Application Image Compilation 1.0.0`
- Upstream Hell language/runtime baseline: `2026-05-29`
- Feature/package version: `1.0.0`
- Cabal package: `hell-application-image-compilation`
- Executable: `hell`
- Git tag: `1.0.0_hell-2026-05-29`
- Release title:
  `Hell 2026-05-29 — Application Image Compilation 1.0.0`
- Artifact stem:
  `hell-application-image-compilation-1.0.0-hell-2026-05-29`

The feature version must never be appended to the upstream baseline. These are
separate version axes: the date identifies the unchanged upstream
language/runtime baseline, while Application Image Compilation identifies and
versions the definitive feature difference.

Release tags use the two-axis grammar
`<AIC-SemVer>_hell-<Hell-YYYY-MM-DD>`. The current tag is therefore
`1.0.0_hell-2026-05-29`. The composite tag is deliberately not SemVer:
GitHub release chronology and the latest release must not be inferred by
SemVer-ordering these tags.

Both axes participate in the immutable tag identity:

- if Hell's next actual upstream version were hypothetically `2026-06-12`,
  an upstream-only release would use `1.0.0_hell-2026-06-12`;
- a hypothetical feature-only release would use
  `1.1.0_hell-2026-05-29`;
- if both hypothetical changes occurred, the tag would be
  `1.1.0_hell-2026-06-12`.

The mapping is deterministic: the same Application Image Compilation version
and Hell version always yield the same tag. There is no revision or counter,
and no new release may be minted without advancing at least one axis. A
correction that retains the Hell version must therefore bump the feature
version, normally its patch component.

## Release gates

The release remains experimental and must not be described as supported until
all of these gates pass on the exact commit to be tagged:

1. Confirm the tag target descends from feature commit `8074dc7` and upstream
   baseline commit `4c5c076`.
2. Review the complete `4c5c076...<tag-target>` diff.
3. Confirm the fixed identity above is consistent in runtime output, package
   metadata, documentation, release title, tag, and artifacts.
4. Confirm `LICENSE` is byte-for-byte unchanged from the upstream baseline.
5. Run `nix build` and `nix flake check` successfully on the tag target.
6. Confirm the normal test suite, dynamic application image check, and
   native-static application image check all ran.
7. Verify each published architecture on an actual compatible Linux target.
8. Validate the exact documentation at the annotated tag locally, including
   API, examples, releases, provenance, support, security, and license links.
   Pages deployment is not part of this release acceptance path.
9. Run `cabal check`, create a source distribution, inspect its contents, and
   build/test from the unpacked source distribution.
10. Confirm no `.serena`, `.agents`, `.codex`, credentials, editor state, or
    build output is tracked or included in source or binary artifacts.
11. Package every binary with `LICENSE`, record the tag and commit, generate
    SHA-256 checksums, and verify the archives after extraction.
12. Push the release-preparation commit, wait for required checks to pass, and
    create an annotated tag at that exact public commit. Candidate tag CI
    requires the peeled tag target to equal the event commit and requires the
    target and current `origin/main` to be on one linear history; diverged or
    unrelated targets are rejected.
13. Let tag CI create or verify the exact draft and its attestations. The
    workflow must stop while the release remains a draft.
14. Review the fork-specific notes, exact six assets, checksums, SBOMs,
    attestations, and tagged documentation. Before publication, merge the exact
    tagged commit into protected `main` without moving the tag, wait for its
    required checks, and confirm the tag target is contained in `origin/main`.
    In the Releases page, explicitly select **Set as latest release**, then use
    **Publish release**. This first reviewed release is intended to be latest;
    do not let GitHub infer that status from the composite tag.
15. After publication, confirm the release displays GitHub's **Latest** badge
    and require the separate read-only publication-verification workflow to
    pass. The already-published `1.0.0_hell-2026-05-29` release is explicitly
    recorded as the sole legacy mutable exception and is verified through its
    exact tag, metadata, assets, digests, and artifact attestations. Enable
    GitHub release immutability externally before any future publication;
    future releases must report immutable and pass their GitHub release
    attestation.

The first release is built from the locked Nix source closure because a release
cannot bootstrap from its own not-yet-published binaries.

## Published-release recovery

Published release identities are immutable by repository policy. Never
force-move, delete and recreate, or reuse a published tag, and never publish
different contents under an existing feature version or artifact name. GitHub
platform immutability was not enabled for the already-published
`1.0.0_hell-2026-05-29` release, so preserve that exact legacy record and
enable the prospective setting before every future release.

If a published release is found to be defective:

1. Stop promoting it and edit its release page to mark it clearly as
   **withdrawn**, stating the reason and the first known affected version.
   Normally retain the tag, release page, assets, `release.json`, and checksums
   as evidence of exactly what was published.
2. If continuing to serve an asset would create a material security or legal
   risk, remove only that asset. Retain the immutable tag and release record,
   and record the removed filename, checksum, reason, and removal date on the
   release page.
3. Fix forward with a new feature/package version, a new tag, new artifact
   names, and a new `release.json`. For example, a correction to 1.0.0 is
   released as Application Image Compilation `1.0.1` under
   `1.0.1_hell-2026-05-29`; the original `1.0.0_hell-2026-05-29` tag is not
   changed. The upstream Hell baseline remains `2026-05-29` unless the new
   release intentionally adopts a different upstream baseline.
4. Link the withdrawn release to its replacement and state in the replacement
   notes that it supersedes the affected version. Update the changelog,
   support policy, Pages documentation, and any release index consistently.
5. Handle security defects through [SECURITY.md](SECURITY.md): use a private
   advisory while coordinating the fix, publish the advisory and impact
   details when disclosure is appropriate, identify all affected versions and
   assets, and direct users to the first fixed release. Do not conceal the
   superseded release history.

## Artifact contract

Append the target and linkage to the fixed stem:

```text
hell-application-image-compilation-1.0.0-hell-2026-05-29-<arch>-linux-<linkage>.tar.xz
```

For example:

```text
hell-application-image-compilation-1.0.0-hell-2026-05-29-x86_64-linux-static.tar.xz
hell-application-image-compilation-1.0.0-hell-2026-05-29-aarch64-linux-static.tar.xz
```

Each archive must contain:

- the `hell` executable;
- the unchanged `LICENSE`;
- `README.md`.

Publish `release.json` with the exact tag, commit, architecture, and linkage.
Publish a `SHA256SUMS` file covering the two archives, two SPDX files, and
`release.json`. Do not upload bare executables.

Generated application images copy the Hell runtime and are binary
redistributions. Their redistributors must accompany them with Hell's
BSD-3-Clause `LICENSE` in documentation or other materials and must not imply
endorsement by Chris Done or other contributors.

## Release notes

Use the 1.0.0 entry in [CHANGELOG.md](CHANGELOG.md) as the basis for a manual
release body. Do not rely solely on auto-generated notes, which may present
inherited upstream commits as fork-authored changes.
