# Hell 2026-05-29 — Application Image Compilation 1.0.0

Hell is a tiny Haskell dialect for shell scripting created by Chris Done. This
repository is an independently maintained fork of
[chrisdone/hell](https://github.com/chrisdone/hell). It is not an official
upstream release and does not imply endorsement by Chris Done or upstream
contributors.

The version has two deliberately separate parts:

- `2026-05-29` is the exact upstream Hell language/runtime baseline.
- `Application Image Compilation 1.0.0` identifies and versions this feature
  line.

The executable remains named `hell`. Its version display is:

```text
Hell 2026-05-29 — Application Image Compilation 1.0.0
```

The first release is GitHub-only and remains experimental until all
[release gates](RELEASE.md) pass. It is not published to Hackage.

## Application Image Compilation

On Linux, `hell` can emit an executable application image containing a
checked, pre-inferred Hell program:

```shell
hell --compile script.hell --output script
# short form
hell --compile script.hell -o script

./script one two
```

Compilation preserves an existing destination by default. Use `--force` only
when replacement is intended:

```shell
hell --compile script.hell -o script --force
```

Keep the `.hell` file as the canonical source and regenerate the application
image whenever its source or runtime changes.

## Important limitations

- Emission is Linux-only and is not cross-compilation.
- The output copies the emitting Hell runtime and inherits its architecture
  and static or dynamic linkage.
- The embedded program is linked and evaluated by that runtime. This is not
  native machine-code compilation.
- Source layout is omitted, but literals, names, and program semantics remain
  recoverable. Application images are not source protection.
- Image format, checksum, operating system, architecture, compiler, and
  runtime ABI are validated. These compatibility checks are not a security
  sandbox.
- An emitted application image cannot emit another application image.
- Ordinary arguments beginning with `-` reach the Hell program. The GHC
  runtime's reserved `+RTS ... -RTS` syntax may consume runtime options first.
- Do not run application images from untrusted sources. They are executables
  and can perform the same operations as the user running them.

See [SUPPORT.md](SUPPORT.md) for the support boundary and
[SECURITY.md](SECURITY.md) for private vulnerability reporting.

## Build and test

The release gate uses Nix:

```shell
nix build
nix flake check
```

`nix flake check` exercises the normal test suite plus dynamically linked and
native-static application image execution. Passing locally is necessary but
does not by itself declare a release supported; the exact tagged commit must
pass every gate in [RELEASE.md](RELEASE.md).

## License and redistribution

Original Hell is Copyright (c) 2023 Chris Done and is distributed under the
[BSD-3-Clause license](LICENSE). The original copyright notice, conditions,
and disclaimer are preserved unchanged.

Generated application images include the Hell runtime. If you redistribute a
generated executable, accompany it with Hell's BSD-3-Clause `LICENSE` in the
documentation or other materials, retain the required notices, and do not
imply endorsement by Chris Done or other contributors.

Release binary archives must contain both the `hell` executable and `LICENSE`.

## Project information

- [Fork provenance](FORK.md)
- [Release history](CHANGELOG.md)
- [Release contract and gates](RELEASE.md)
- [Support policy](SUPPORT.md)
- [Security policy](SECURITY.md)
- [Contribution guide](.github/CONTRIBUTING.md)
- [Fork repository](https://github.com/Portfoligno/hell-application-image-compilation)
- [Fork documentation](https://portfoligno.github.io/hell-application-image-compilation/)
- [Upstream Hell](https://github.com/chrisdone/hell)

Maintainer: Nicholas Yip <nicholasyip@obceit.cc>
