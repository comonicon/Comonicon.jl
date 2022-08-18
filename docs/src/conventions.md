# Syntax & Conventions

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

# Doc String Syntax

the docstring of each `@cast` or `@main` annotated object have a few special section.
The function or module signature is ignored for generating CLI help page, 

## Description

The description of the command is seperated as brief and detailed description.
The special sections are organized as following:

- The brief description is the first paragraph of the docstring.
- The long detailed description can be specified using `#Intro` or `#Introduction` section.

for example

```julia
"""
    command(args1, args2, args3, args4)

the brief description of the command.

# Intro

the long description of the command,
asdmwds dasklsam xasdklqm dasdm, qwdjiolkasjdsa
dasklmdas weqwlkjmdas kljnsadlksad qwlkdnasd
dasklmdlqwoi, dasdasklmd qw,asd. dasdjklnmldqw.
"""
```

## Arguments

The argument description can be specified using `#Args` or `#Arguments` section.
The syntax must be

```md
- `<arg name>`: <description of the argument>
```

for example

```julia
"""
    command(args1, args2, args3, args4)

the brief description of the command.

# Intro

the long description of the command,
asdmwds dasklsam xasdklqm dasdm, qwdjiolkasjdsa
dasklmdas weqwlkjmdas kljnsadlksad qwlkdnasd
dasklmdlqwoi, dasdasklmd qw,asd. dasdjklnmldqw.

# Args

- `arg1`: argument 1.
- `arg2`: argument 2.
- `arg3`: argument 3.
- `arg4`: argument 4.
"""
```

## Options

the options can be specified in `#Options` section, the option
must have a prefix `--`, and optionally have `-<first letter>`
to specify its short option. All underscore `_` in the option name
will be converted to a dash `-` for option names, for example.

The value string after `=` (e.g `-s=<value>`) can give user specified hint
or the default hint will be the default value's Julia expression.

```md
# Options

- `--short, -s`: short option using default hint.
- `--short-space, -s <value>`: short option using given hint.
- `--short-assign, -s=<value>`: short option using given hint.
- `--long`: long option using default hint.
- `--long-space <value>`: long option using given hint.
- `--long-assign=<value>`: long option using given hint.
- `--short_underscore, -s <value>`: short option with underscore.
```

## Flags

the flags can be specified using `#Flags` section, the rest are similar to
`#Options` except there are no value hints.

# Special Arugment/Options Types

there are a few special argument/option types defined to generate special shell completions.

```@autodocs
Modules = [Comonicon.Arg]
```

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

