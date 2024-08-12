# [CLI Project](@id project)

To build better, faster and more complicated CLI, you will want to build your CLI in a Julia package
and deliver it to your users. I will introduce how to create a Comonicon CLI project in this chapter.

## Create a Julia Comonicon project

A Comonicon CLI project is first a Julia project, thus you should first
create a Julia project. If you don't know what is a Julia project, please
read about the Pkg section of [creating packages](https://julialang.github.io/Pkg.jl/v1/creating-packages/). The minimal requirement of a Julia Comonicon project is the
following structure

```sh
Demo
├── LICENSE
├── Manifest.toml
├── Project.toml
├── README.md
├── src
│   └── Demo.jl
└── test
    └── runtests.jl
```

## Use `@cast` to define multiple commands

In a large project, one might need to define multiple
commands. This can be done via `@cast`.

```@docs
@cast
```

`@cast` is similar to `@main` before functions, but it won't execute anything, but only create
the command and register the command to a global variable `CASTED_COMMANDS` in the current module.
And it will create `NodeCommand`s before modules, and the sub-commands of the `NodeCommand` can
be created via `@cast` inside the module.

After you create the commands via `@cast`, you can declare an entry at the bottom of your module
via `@main`. A simple example looks like the following

```julia
module Demo

using Comonicon

@cast mycmd1(arg; option="Sam") = println("cmd1: arg=", arg, "option=", option)
@cast mycmd2(arg; option="Sam") = println("cmd2: arg=", arg, "option=", option)

"""
a module
"""
module Cmd3

using Comonicon

@cast mycmd4(arg) = println("cmd4: arg=", arg)

end # module

@cast Cmd3

"""
my demo Comonicon CLI project.
"""
@main

end # module
```

You can find all created commands via following

```julia
julia> Demo.CASTED_COMMANDS
Dict{String,Any} with 4 entries:
  "mycmd2" => mycmd2 [options] <arg>
  "cmd3"   => cmd3 <command>
  "main"   => demo v0.1.0
  "mycmd1" => mycmd1 [options] <arg>
```

and you can execute the command via `Demo.command_main` created by `@main`:

![project-demo](assets/images/project-demo.png)

## Setup the `build.jl`

Then you can create a `build.jl` file in your package `deps` folder to install this command to `~/.julia/bin`
when your user install your package. This will only need one line:

```julia
# build.jl
using Demo; Demo.comonicon_install()
```

To learn about how to use it, you can type

```sh
julia --project deps/build.jl -h
```

which will print the following help message:

![build-help](assets/images/build-help.png)

## Install the CLI

You can now install the CLI by building the package either in REPL via `]build`
or use IonCLI in terminal via

```sh
ion build # in Demo folder
```

This will install this command to `~/.julia/bin` directory by default, if you have put this directory in your `PATH` then you will be able to use the command
`demo` directory in your terminal, e.g

```sh
demo -h
```

## Enable System Image

Some CLI projects are quite complicated thus the startup latency is still
quite huge even the package module is precompiled. In this case, one will want
to use a system image to reduce the startup latency.

You can enable to the system image build by specifying `[sysimg]` field in
your Comonicon configuration file `Comonicon.toml` (or `JuliaComonicon.toml`).

```toml
name = "demo"

[install]
completion = true
quiet = false
optimize = 2

[sysimg]
```

You can also specify more detailed system image compilation options, e.g

```toml
[sysimg]
incremental=false
filter_stdlibs=true
```

You can find more references for these options in [PackageCompiler#create_sysimage](https://julialang.github.io/PackageCompiler.jl/dev/refs.html#PackageCompiler.create_sysimage).

However, you may still find it being slow, you can further reduce the latency
by adding an execution file to record precompilation statements.

```toml
[sysimg.precompile]
execution_file = ["deps/precompile.jl"]
```

or you can manually specify these precompile statements via

```toml
[sysimg.precompile]
statements_file = ["deps/statements.jl"]
```

you can learn more about how to create precompilation statements via [SnoopCompile](https://timholy.github.io/SnoopCompile.jl/stable/) and [create a
`userimg.jl`](https://timholy.github.io/SnoopCompile.jl/stable/userimg/) as the precompilation statements.

## Enable Application Build

You can build a standalone application similar to building a system image as well, e.g

```toml
[application]
incremental=true
filter_stdlibs=false

[application.precompile]
statements_file = ["deps/statements.jl"]
```

## Further Reference
The CLI we just used to create this project serves as the best practice for
Comonicon, you can take it as a reference: [Ion.jl](https://github.com/Roger-luo/Ion.jl).
