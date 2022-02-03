# Conventions

## Basics

**leaf command**: leaf commands are the commands at the last of the CLI that takes arguments,
options and flags, e.g the `show` command below

**node command**: node commands are the commands at the middle or first of the CLI that contains sub-commands,
e.g the `remote` command below

```sh
git remote show origin
```

**arguments**: arguments are command line arguments that required at the leaf command

**flags**: flags are command line options that has no arguments, e.g `--flag` or `-f` (short flag).

**options**: options are command line options that has arguments, e.g `--name Sam` or `-n Sam`, also `--name=Sam` or `-nSam`.

When used on function expressions, `@cast` and `@main` have the same convention on how they
convert your expressions to commands, these are

- function arguments are parsed as command arguments:
  - value will be converted automatically if arguments has type annotation
  - optional arguments are allowed
- function keyword arguments are parsed as command flags or options:
  - keyword arguments must have default value
  - keyword arguments of type `Bool` can only have `false` as default value, which will be treated as flags that allow short flags.
  - value will be converted automatically if keyword arguments has type annotation
- function doc string can use section names: **Arguments**, **Options** and **Flags** to annotate your CLI:
  - short options or short flags can be declared via `-f, flag` or `-o, --option <name>` (see example below)

!!! note
    to be compatible with shell options, variable names with underscore `_` will be automatically replaced with dash `-`.   As a result, the corresponding doc string should use dash `-` instead of `_` as well, e.g kwargs name `dash_dash` will be converted to `--dash-dash` option/flag in terminal, and its corresponding doc string should be ``` - `--dash-dash`: <arg>```.

# Dash Seperator

Dash seperator `--` is useful when the CLI program contains scripts that accepts command line inputs, e.g a custom command `run` that execute Julia script

```sh
run --flag -- script.jl a b c
```

one will need to seperate the input of `run` and `script.jl` for disambiguity sometimes,then the dash seperator comes useful for this case.

# Plugins

Most complicated CLIs support plugins, this is acheived by checking
if there is a command line executable with the following name pattern

```
<main command name>-<plugin name>
```

for example, `git` have plugin program called `git-shell`
and can be called as `git shell`, this is by default turned
off, but one can enable this feature by setting the following
in `(Julia)Comonicon.toml`

```toml
[command]
plugin=true
```
