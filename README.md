# Comonicon

*gith averminaluk ayh juldas mausan urdan*

[![Build Status](https://travis-ci.com/Roger-luo/Comonicon.jl.svg?branch=master)](https://travis-ci.com/Roger-luo/Comonicon.jl)

Roger's magic book for command line interfaces.

## Installation

<p>
Comonicon is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://julialang.org/favicon.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install Comonicon,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd> key in the REPL to use the package mode, then type the following command
</p>

For stable release

```julia
pkg> add Comonicon
```

For current master

```julia
pkg> add Comonicon#master
```

## Usage

The simplest way to use it is via `@command_main` macro, please refer to the demo in [Zero Duplication](#zero-duplication).

Although you can use `Comonicon` in your script, but the recommended way to build CLI with Comonicon is to use `@command_main` in a Julia project module, so the command line interface entry will get compiled by the
Julia compiler.

Moreover, if you wish to create multiple commands. You can use `@cast` macro to annotate a function or module
to create more complicated command line interfaces. You can check the example `Ion` [here](example/Ion).

## Features
### Zero Duplication
The frontend `@command_main` and `@cast` will try to parse everything you typed and turn them into
part of your command line. This includes your function or module docstrings, your argument and keyword
argument names, types and default values.


```julia
"""
ArgParse example implemented in Comonicon.

# Arguments

- `x`: an argument

# Options

- `--opt1 <arg>`: an option
- `-o, --opt2 <arg>`: another option

# Flags

- `-f, --flag`: a flag
"""
@command_main function main(x; opt1=1, opt2::Int=2, flag=false)
    println("Parsed args:")
    println("flag=>", flag)
    println("arg=>", x)
    println("opt1=>", opt1)
    println("opt2=>", opt2)
end
```

We don't want to compromise on writing DRY code. If you have mentioned it in the documentation, you shouldn't write
about it again in your code. This is like Python [docopt](https://github.com/docopt/docopt) but with [Fire](https://github.com/google/python-fire) and in Julia.

### Zero Overhead
The backend code generator will generate Julia ASTs directly to parse your command line inputs all in one
function `command_main` with one method `command_main(::Vector{String})`, which can be precompiled easily during module compilation.

### Zero Dependency
You can get rid of `Comonicon` entirely after you generate the command line parsing script
via `write(filename, command_object)`. If means if you copy this file into your script, you
will get a standalone Julia script (unless the script depends on something else).


## License

MIT License
