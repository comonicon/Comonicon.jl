<!-- =============================
     ABOUT
    ============================== -->

\begin{:section, title="About this Package", name="About"}

\lead{Comonicon.jl is a Command Line Interface (CLI) generator that aims to provide simple, powerful and fast CLI experience in Julia language}

* **minimal user input**:
  * python-fire like workflow turns your functions and modules into CLIs.
  * directly parse your function docstring to annotate your CLI commands, arguments and options.
* **zero dependency**. you can dump the generated entry function into script and remove the dependency of Comonicon itself.
* **colorful** help string and builtin **help message composition** (copied and modified from [Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl))
* **fast!**
  * `command_main` can be easily precompiled by Julia compiler
  * Comonicon also ships a set of tools to help you compile/interpret your script


\center{
  \figure{path="/assets/ion.png", width="100%", style="border-radius:5px;", caption="A command line package manager ion built using Comonicon"}
}

\end{:section}

<!-- =============================
     GETTING STARTED
     ============================== -->
\begin{:section, title="Getting started"}

In order to get started, just add the package (with **Julia ≥ 1.3**)

```julia-repl
pkg> add Comonicon
```

and create your first command line script

```julia
using Comonicon

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

command_main()
```
\end{:section}

\begin{:section, title="Conventions"}

\lead{
  The frontend of Comonicon uses the following convention to map your Julia script to a CLI.
}

Comonicon's frontend restricts the convention to a less flexible but powerful enough
semantic, this is a design choice. For more complicated and customized CLI, you should
refer to the documentation and use the CLI constructors directly.

### Functions

functions are converted as `LeafCommand`, which is always the last command in your CLI.

```julia
@cast function command(arg1, arg2="name"; opt1::Float64=0.1, flag::Bool=false)
end
```

- function arguments `arg1` and `arg2` are treated as command arguments
- function keyword arguments are mapped via the following rules:
  - if the keyword argument is a `Bool` with default value `false`, it will be treated as a flag (e.g the `flag` above)
  - keyword argument of `Bool` type with default value `true` is not allowed
  - other kinds of keyword arguments are treated as options by default unless you mentioned it is a flag in the docstring.
  - short options are enabled by declaring it in docstring
  - all flags have short options


### Modules

modules are converted to `NodeCommand`, it must contain either `NodeCommand` or `LeafCommand`, e.g

```sh
git remote add origin <url>
```

here `remote` is a `NodeCommand` and `add` is a `LeafCommand`.

### Doc Strings

There are only three sections of the doc string will be parsed as annotations, a typical
doc string of a Comonicon command looks like following

```julia
"""
command description.

# Arguments

- `arg1`: description of the first argument
- `arg2`: description of the second argument

# Options

- `-o,--opt1 <name>`: description of the first option

# Flags

- `-f,--flag`: description of the flag
"""
```

You can still have other sections in the docstring, but these sections will be skipped
in your CLI help doc currently.

\end{:section}

\begin{:section, title="Workflow"}

However, since this is not created inside a project, Julia will not cache the compilation.
A better workflow is to create CLI as Julia projects.

```julia
module Dummy
using Comonicon

"""
foo foo

# Arguments

- `x`: an argument

# Options

- `--foo <foo>`: foo foo
"""
@cast function foo(x::Int, y; foo::Int=1, hulu::Float64=2.0, flag::Bool=false) where T
    @show x
    @show y
    @show foo
    @show hulu
    @show flag
end

"""
tick tick.

# Arguments

- `xx`: xxxxxxxxxxxx
- `yy`: yyyyyyyyyyyy
"""
@cast function tick(xx::Int, yy::Float64=1.0)
    @show xx
    @show yy
end

@command_main name="main" doc="""
dummy command. dasdas dsadasdnaskdas dsadasdnaskdas
sdasdasdasdasdasd adsdasdas dsadasdas dasdasd dasda
"""
end # Dummy
```

When called inside a project module (not `Main`), the `@command_main` macro will
generate a precompile statement for your CLI entry, so the entry will get precompiled
while precompiling the project. Then you can write a `deps/build.jl` script to
install your CLI to `.julia/bin`

```julia
using Comonicon, IonCLI
Comonicon.install(Dummy, "dummy")
```


\end{:section}
