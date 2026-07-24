# Hell 2026-05-29 — Application Image Compilation 1.0.0

This repository is an independently maintained fork of
[Chris Done's Hell](https://github.com/chrisdone/hell), a tiny Haskell dialect
for shell scripting. It is not an official upstream release and does not imply
endorsement by Chris Done or upstream contributors.

This feature line preserves the upstream Hell language/runtime baseline
`2026-05-29` and adds **Application Image Compilation 1.0.0** on Linux. Fork
documentation and releases are published by
[Portfoligno/hell-application-image-compilation](https://github.com/Portfoligno/hell-application-image-compilation).
For the original project and its history, see
[chrisdone/hell](https://github.com/chrisdone/hell).

This release remains experimental until every gate in
[RELEASE.md](../RELEASE.md) passes.

## Application Image Compilation

On Linux, this feature line can turn a Hell script into an executable
application image:

```shell
hell --compile script.hell --output script
# or: hell --compile script.hell -o script
./script one two
```

Keep `script.hell` as the canonical source and regenerate the executable after
changing it. The emitter copies the running Hell runtime and embeds a checked,
pre-inferred program image in a bounded, versioned format. The result inherits
the runtime's operating system, architecture, and linkage: a static Linux Hell
produces a static Linux image, while a dynamically linked Hell produces a
dynamically linked image. This is not cross-compilation, native machine-code
compilation, or a source-protection mechanism. Source layout is omitted, but
literals, names, and program semantics remain recoverable.

Program arguments, including ordinary arguments beginning with `-`, pass to
the embedded Hell program. The executable still uses the GHC runtime, whose
reserved `+RTS ... -RTS` argument syntax may consume runtime options before the
program receives its arguments.

Compilation refuses to overwrite an existing output by default; add `--force`
to replace it:

```shell
hell --compile script.hell -o script --force
```

An application image is not sandboxed and should be treated like any other
executable. Do not run untrusted images. Images validate their format,
checksum, target, and runtime ABI, but those checks do not establish that an
image is safe.

## License and redistribution

Hell was created by Chris Done. This fork is distributed under the
BSD-3-Clause license; see [LICENSE](../LICENSE).

Generated application images include the Hell runtime. If you redistribute a
generated executable, accompany it with Hell's BSD-3-Clause `LICENSE` in the
documentation or other materials, retain the required notices, and do not
imply endorsement by Chris Done or other contributors.

See [FORK.md](../FORK.md) for provenance,
[SUPPORT.md](../SUPPORT.md) for the support boundary, and
[SECURITY.md](../SECURITY.md) for private vulnerability reporting.
