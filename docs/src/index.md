# Comonicon

*gith averminaluk ayh juldas mausan urdan*

[![Build Status](https://travis-ci.com/Roger-luo/Comonicon.jl.svg?branch=master)](https://travis-ci.com/Roger-luo/Comonicon.jl)

Roger's magic book for command line interfaces.


## Quick Start

The simplest and most common way to use [`Comonicon`](@ref) is to use `@cast` and `@main`.
Let's use a simple example to show how, the following example creates a command using
`@cast`.

```julia
using Comonicon
@main function mycmd(arg; option="Sam", flag::Bool=false)
    @show arg
    @show option
    @show flag
end
```

if you write this into a script file `myscript.jl` and execute it using

```sh
julia myscript.jl -h
```

You will see the following in your terminal.

```
  main

No documentation found.
mycmd is a Function.
# 1 method for generic function "mycmd":
[1] mycmd(arg; option, flag) in Main at /Users/roger/.julia/dev/Comonicon/example/myscript.jl:2

Usage

  main [options...] [flags...] <arg>

Args

  <arg>

Flags

  -f,--flag

  -h, --help          print this help message

  -V, --version       print version information

Options

  --option <::Any>

```

Now let me explain what `@main` does here. In short it does the following things:

- parse your expression and create a command line object
- use this command line object to create an entry
- generate a Julia script to actually execute the command
- cache the generated Julia script into a file so it won't need to recompile your code again

## Convention

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

  to be compatible with shell options, variable names with underscore `_` will be automatically replaced with dash `-`.
  As a result, the corresponding doc string should use dash `-` instead of `_` as well, e.g kwargs name `dash_dash` will
  be converted to `--dash-dash` option/flag in terminal, and its corresponding doc string should be ``` - `--dash-dash`: <arg>```.

An example of function docstring

```julia
"""
my command line interface.

# Arguments

- `arg`: an argument

# Options

- `-o, --option`: an option that has short option.

# Flags

- `-f, --flag`: a flag that has short flag.
"""
@main function mycmd(arg; option="Sam", flag::Bool=false)
    @show arg
    @show option
    @show flag
end
```

This will give a help message looks like below after execute this in `myscript.jl` via `julia myscript.jl`

```

  main

my command line interface.

Usage

  main [options...] [flags...] <arg>

Args

  <arg>                  an argument

Flags

  -f,--flag              a flag that has short flag.

  -h, --help             print this help message

  -V, --version          print version information

Options

  -o, --option <name>
```

## Create a CLI project

However, to build better and faster CLI, you will want to build your CLI in a Julia package
and deliver it to your users. This can be done via `@cast`.

`@cast` is similar to `@main` before functions, but it won't execute anything, but only create
the command and register the command to a global variable `CASTED_COMMANDS` in the current module.
And it will create `NodeCommand`s before modules, and the sub-commands of the `NodeCommand` can
be created via `@cast` inside the module.

After you create the commands via `@cast`, you can declare an entry at the bottom of your module
via `@main`. A simple example looks like the following

```julia
module Dummy

using Comonicon

@cast mycmd1(arg; option="Sam") = println("cmd1: arg=", arg, "option=", option)
@cast mycmd2(arg; option="Sam") = println("cmd2: arg=", arg, "option=", option)

module Cmd3

using Comonicon

@cast mycmd4(arg) = println("cmd4: arg=", arg)

end # module

@main name="dummy" version=v"0.1.0"

end # module
```

You can find all created commands via following

```julia
julia> Dummy.CASTED_COMMANDS
Dict{String,Any} with 3 entries:
  "mycmd2" => mycmd2 [options...] <arg>
  "main"   => dummy v0.1.0
  "mycmd1" => mycmd1 [options...] <arg>
```

and you can execute the command via `Dummy.command_main` created by `@main`:

```julia
julia> Dummy.command_main(["-h"])

  dummy v0.1.0



Usage

  dummy <command>

Commands

  mycmd2 [options...] <arg>    No documentation found. Main.Dummy.mycmd2 is a
                               # 1 method for generic function "mycmd2": [1]
                               option) in Main.Dummy at REPL[2]:6

  mycmd1 [options...] <arg>    No documentation found. Main.Dummy.mycmd1 is a
                               # 1 method for generic function "mycmd1": [1]
                               option) in Main.Dummy at REPL[2]:5

Flags

  -h, --help                   print this help message

  -V, --version                print version information


0
```

Then you can create a `build.jl` file in your package `deps` folder to install this command to `~/.julia/bin`
when your user install your package. This will only need two line:

```julia
# build.jl
using Comonicon, Dummy
Comonicon.install(Dummy, "dummy")
```

You can turn on the keyword `sysimg` to `true` to compile a system image for the CLI.

```julia
# build.jl
using Comonicon, Dummy
Comonicon.install(Dummy, "dummy"; sysimg=true)
```

There is an example project [IonCLI.jl](https://github.com/Roger-luo/IonCLI.jl) you can take as
a reference.
