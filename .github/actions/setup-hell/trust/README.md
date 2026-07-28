# Reviewed trust data

This directory is intentionally unpinned before the first reviewed
`1.0.0_hell-2026-05-29` publication. That already-published release is the
explicit legacy mutable exception: it has artifact attestations but no GitHub
immutable-release attestation. Do not add zeroes,
examples, dummy hashes, or selectable fallback values.

The required files and review chronology are documented in the parent
directory. `READY` must be added only with all six real architecture trust
files.

Activating `READY` also requires a reviewed cache-schema/key revision in
`action.yml` that is bound to the published archive and member digests. The
pre-publication key is deliberately not authoritative and must not be reused
after trust activation.
