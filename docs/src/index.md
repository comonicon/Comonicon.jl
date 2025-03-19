# Comonicon

*gith averminaluk ayh juldas mausan urdan*

[![Build Status](https://github.com/comonicon/Comonicon.jl/workflows/CI/badge.svg)](https://github.com/comonicon/Comonicon.jl/actions)
[![codecov](https://codecov.io/gh/comonicon/Comonicon.jl/branch/master/graph/badge.svg?token=zZjCxCiFTY)](https://codecov.io/gh/comonicon/Comonicon.jl)

Roger's magic book for command line interfaces.

```@docs
Comonicon
```

## Quick Start

The simplest and most common way to use [`Comonicon`](@ref) is to use `@cast` and `@main`.

```@docs
@main
```

Let's use a simple example to show how, the following example creates a command using `@main`.

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

![myscript-help](assets/images/myscript.png)

If you want to add some description to your command, you can just write it as
a Julia function doc string, e.g

```julia
using Comonicon

"""
my first Comonicon CLI.
"""
@main function mycmd(arg; option="Sam", flag::Bool=false)
    @show arg
    @show option
    @show flag
end
```

![myscript-help-docstring](assets/images/myscript-doc.png)

but you might also want to have more detailed help message for your CLI arguments
and options, you can specify them via doc string:

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

![mycmd-option-doc](assets/images/mycmd-option-doc.png)

Now, you can directly use this script from command line in this way. But if you want to make it accessible in shell, should do the following:

- create a file without any extension called `mycmd`
- copy the script above
- add the following line on the top of your script `mycmd` (this is called [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))):

```sh
#!<path to your julia executable>
```

now your `mycmd` script should look like the following

```julia
#!<path to your julia executable>
using Comonicon

"""
my first Comonicon CLI.
"""
@main function mycmd(arg; option="Sam", flag::Bool=false)
    @show arg
    @show option
    @show flag
end
```

- now we need to give this file permission via `chmod`:

  ```sh
  chmod +x mycmd
  ```

- you can now execute this file directly via `./mycmd`, if you want to be able to execute
  this cmd directly from anywhere in your terminal, you can move this file to `.julia/bin`
  folder, then add `.julia/bin` to your `PATH`

  ```sh
  export PATH="$HOME/.julia/bin:$PATH"
  ```

## What's under the hood?

Now let me explain what `@main` does here. In short it does the following things:

- parse your expression and create a command line object
- use this command line object to create an entry (See [Conventions](@ref) section to read about its convention)
- generate a Julia script to actually execute the command
- cache the generated Julia script into a file so it won't need to recompile your code again

## Developer Recommendations

For simple and small cases, a CLI script is sufficient.

However, for larger projects and more serious usage, one should [create a Comonicon CLI project](@ref project) to use the full power of Comonicon. You will be able
to gain the following features for free in a Comonicon project:

- much faster startup time
- automatic CLI installation
- much easier to deliver it to more users:
  - can be registered and installed as a Julia package
  - distributable system image build in CI (powered by [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl))
  - distributable standalone application build in CI (powered by [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl))
