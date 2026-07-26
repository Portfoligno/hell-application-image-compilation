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
- Git tag: `application-image-compilation/v1.0.0`
- Release title:
  `Hell 2026-05-29 — Application Image Compilation 1.0.0`
- Artifact stem:
  `hell-application-image-compilation-1.0.0-hell-2026-05-29`

The feature version must never be appended to the upstream baseline. These are
separate version axes: the date identifies the unchanged upstream
language/runtime baseline, while Application Image Compilation identifies and
versions the definitive feature difference.

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
    create an annotated tag at that exact public commit.
13. Let tag CI create or verify the exact draft and its attestations. The
    workflow must stop while the release remains a draft.
14. Review the fork-specific notes, exact six assets, checksums, SBOMs,
    attestations, and tagged documentation, then use the Releases page
    **Publish release** button.
15. Require the separate read-only publication-verification workflow to pass.

The first release is built from the locked Nix source closure because a release
cannot bootstrap from its own not-yet-published binaries. The repository setup
action becomes supported only after the published native archive and member
digests have been reviewed into its trust data. Those trust files are not a
seventh release asset.

## Published-release recovery

Published release identities are immutable. Never force-move, delete and
recreate, or reuse a published tag, and never publish different contents under
an existing feature version or artifact name.

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
   `application-image-compilation/v1.0.1`; the original 1.0.0 tag is not
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
