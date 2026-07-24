# Reviewed trust data

This directory is intentionally unpinned before the first immutable
`application-image-compilation/v1.0.0` publication. Do not add zeroes,
examples, dummy hashes, or selectable fallback values.

The required files and review chronology are documented in the parent
directory. `READY` must be added only with all six real architecture trust
files.

Activating `READY` also requires a reviewed cache-schema/key revision in
`action.yml` that is bound to the published archive and member digests. The
pre-publication key is deliberately not authoritative and must not be reused
after trust activation.
