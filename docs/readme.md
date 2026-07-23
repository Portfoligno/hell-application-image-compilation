# hell 😈

Hell is a scripting language that is a tiny dialect of Haskell.

See [homepage](https://chrisdone.github.io/hell/) for documentation, downloads, architecture, etc.

## Compiled application images

On Linux, Hell can turn a script into an executable application image:

```shell
hell --compile script.hell --output script
# or: hell --compile script.hell -o script
./script one two
```

Keep `script.hell` as the canonical source and regenerate the executable after changing it. Version 1 copies the running Hell runtime and embeds a pre-inferred program image, so the result inherits that runtime's platform, architecture, and linkage: a static Linux Hell produces a static Linux image, while a dynamically linked Hell produces a dynamically linked image. It is not native machine code or a source-protection mechanism; source layout is omitted, but literals, names, and program semantics remain recoverable.

Arguments to the generated executable, including arguments beginning with `-`, pass directly to the Hell program. Compilation refuses to overwrite an existing output by default; add `--force` to replace it:

```shell
hell --compile script.hell -o script --force
```

Note: this project and its source code is an LLM-free zone. All the source was typed up by me and contributors. 

License: this project has a liberal license and sits, painstakingly, in one Haskell file: it is intended to be read and forked for other use cases!
