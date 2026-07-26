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

## Native CI cache

The public, self-signed Cachix cache is `hell-app-image-compilation`. Its exact
reviewed public key is:

    hell-app-image-compilation.cachix.org-1:OLLZe3quWexZQiUZpUIsAXMA3qqnivZELoJA32ch+PE=

Every Nix installation commits that literal key, the literal
`https://hell-app-image-compilation.cachix.org?priority=30` substituter, and
`require-sigs = true`. It also sets `always-allow-substitutes = false`, so
derivation-level `allowSubstitutes = false` is not globally bypassed by the
installer's CI default. Neither namespace nor key comes from repository
variables or a network response. `fallback = true` and bounded transfer
timeouts make an unavailable or empty cache an ordinary cold Nix build; no
product build, check, or release gate is skipped.

Every same-repository branch push runs the unprivileged `Cache request`
workflow. It has read-only permission, executes no repository code, and has no
cache credential. The trusted default-branch `workflow_run` definition accepts
only requests whose original event is `push` and whose head repository exactly
equals the current repository. It has no `main`, protected-branch, conclusion,
or head-branch filter: same-repository push authority is intentionally the
request boundary. Fork pushes and pull-request events receive no writer
credential.

Each independent cache matrix job checks out two immutable trees. The
requesting `head_sha` is checked out under `request` and may only participate
in a synchronous, sandboxed Nix build of one fixed matrix target while every
GitHub and Cachix token is absent. The checker and locked
Cachix client are built separately from the trusted `github.workflow_sha`
checkout under `trusted`; the requesting SHA never supplies either executable.
A trusted policy pass, exact output-path match, non-substitutable forbidden-leaf
assertion, recursive-closure exclusion, and 50 GiB ceiling all complete before
credentials are exposed.

The pinned Nix installer injects the workflow token into its own trusted
installation step unless its explicit input is nonempty. The writer supplies
the fixed non-secret `disabled` sentinel, appends an empty `access-tokens`, and
then builds a trusted Hell checker from `github.workflow_sha`. Before any
requesting source is checked out, that checker verifies the effective Nix
configuration, the reviewed raw sentinel, environment, netrc, and
system/global Git configuration. After both credential-nonpersistent
checkouts, it repeats those checks and also inspects both local Git
configurations before any requesting build.

Only the job's final step receives the two Cachix secrets, and that step runs
under `always()` only when the stable `build-cache-root` and
`validate-cache-closure` steps both succeeded. The intervening informational
size diagnostic therefore cannot discard an already-approved immutable root.
The publisher runs only the trusted client against the validated output link. No
requesting-branch executable runs after credentials enter the step
environment, and no daemon or whole-store scan is used. The write token is
scoped to `hell-app-image-compilation` and stored only as
`CACHIX_AUTH_TOKEN`; the signing key is stored only as `CACHIX_SIGNING_KEY`.

The current authority is fourteen system/target jobs: each of
`automation-checks`, `cache-seed-static-toolchain`,
`cache-seed-static-haskell`, `automation-release-build`,
`automation-release-control`, `automation-tests`, and `automation` on both
native systems. The writer runs independently of Test success.
`fail-fast: false` and one
matrix job per static toolchain group, static Haskell group, split automation
image, or dispatcher mean a later failure does not erase groups already
validated and pushed. Its single global concurrency group uses
`cancel-in-progress: false`, so a newer push cannot starve an in-progress
population; GitHub retains at most the newest pending run. GitHub and runner
capacity schedule matrix jobs without a workflow-level parallelism cap, while
each job retains `--max-jobs 1` and a 180-minute timeout to bound its local
resource use. The redundant global `cache-seed` link farm and publication
target have been removed because they added no reusable member that the
retained roots did not already cover.

The flake also exposes prospective v2 C/runtime, static-compiler, and exact
five-image automation link farms. They are not publication targets. The
compatibility static-toolchain root and current static-Haskell root remain
authoritative until both-system direct membership is qualified and literal
per-system closure-byte and path-count ceilings are reviewed. Only then may a
separate change activate the final six-target writer.

The writer never selects dynamic or static product leaves, check outputs,
release bundles, workspaces, Cabal state, credentials, or release assets as
cache roots. Building a split automation image necessarily realizes the
dynamic product executable that compiles it; explicit image-only pushes keep
that builder out of the uploaded runtime closure. Product, check, and release
leaves are marked `allowSubstitutes = false` and `preferLocalBuild = true`.
Trusted closure checks reject branch aliases that resolve an authorized matrix
name to any such leaf. Release and published-verification workflows never
receive cache credentials.

Nix signature and NAR-hash verification remain required. `fallback = true`
and bounded transfer retries make a miss or cache outage a slower local build,
not a correctness bypass. A valid cache signature means the object was
authorized by the cache signer; it is not independent provenance. Release and
published-verification jobs locally rebuild and compare cached top-level
automation images before executing them.

Treat the self-signing key as a code-execution trust root. After suspected
token or signing-key exposure, revoke the token, remove the substituter and
public key from every workflow, create `hell-app-image-compilation-v2` with a
new key pair, cold-build and qualify both native systems, and activate v2 in a
reviewed change. Never reuse the old namespace or key.

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
