# Security policy

## Current status and supported versions

Application Image Compilation 1.0.0 is experimental until every release gate
in [RELEASE.md](RELEASE.md) passes. Before a tagged release passes those gates,
there is no supported release.

After publication, only the latest tagged release from
[Portfoligno/hell-application-image-compilation](https://github.com/Portfoligno/hell-application-image-compilation)
receives security fixes. Upstream `chrisdone/hell` releases are maintained by
the upstream project, not here.

## Security boundary

Application images are executable programs, not sandboxes. Do not run an image
from an untrusted source. Format, checksum, target, and ABI validation detect
malformed or incompatible images; they do not establish that the embedded
program is safe.

Emission is Linux-only. Generated images inherit the emitting runtime's
architecture and static or dynamic linkage. The GHC runtime and all packaged
dependencies remain part of the security boundary.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Use GitHub's
[private vulnerability reporting](https://github.com/Portfoligno/hell-application-image-compilation/security/advisories/new)
or email Nicholas Yip at <nicholasyip@obceit.cc>.

Include:

- the affected release tag and `hell --version` output;
- operating system, architecture, and whether the runtime is static or
  dynamically linked;
- reproduction steps or a proof of concept;
- expected impact;
- whether the issue concerns image creation, image loading, ABI validation,
  executable installation, or ordinary Hell execution; and
- any proposed remediation or disclosure constraints.

Receipt and remediation are handled on a best-effort basis; no response-time
or fix-time guarantee is made. Public disclosure should be coordinated until
a fix or mitigation is available.
