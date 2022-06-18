const Maybe{T} = Union{Nothing,T}

"""
    abstract type ComoniconExpr end

Abstract type for Comonicon CLI expression.
"""
abstract type ComoniconExpr end

"""
    struct Description <: ComoniconExpr

type for description of a command object.

# Fields

- `brief::String`: brief introduction of the command,
    will be printed as the first sentence
    of the whole description as well as brief intro in
    upper level help info.
- `content::String`: long introduction of the command.

# Constructors

```julia
Description(;brief="", content="")
Description(brief)
```
"""
Base.@kwdef struct Description <: ComoniconExpr
    brief::String = ""
    content::String = ""
end

Base.convert(::Type{Description}, s::AbstractString) = Description(String(s))
Base.convert(::Type{Description}, ::Nothing) = Description()
Description(text::String) = Description(text, "")
Description(::Nothing) = Description()

"""
    struct Argument <: ComoniconExpr

type for positional argument of a command.

# Fields

- `name::String`: name of the argument.
- `type`: type of the argument, default `Any`.
- `vararg::Bool`: if the argument is a variant argument, default `false`.
- `require::Bool`: if the argument is required, default `true`.
- `default::Maybe{String}`: the default value of this argument if argument is not required (optional), default `nothing`.
- `description::Description`: the description of this argument, default `Description()`.
- `line::Maybe{LineNumberNode}`: the line number of this argument, default is `nothing`.

# Constructors

```julia
Argument(fields_above...)
Argument(;fields_above...)
```
"""
Base.@kwdef struct Argument <: ComoniconExpr
    name::String
    type = Any
    vararg::Bool = false
    require::Bool = true
    # this is only for docs, since Julia
    # function will handle the actual default
    # value
    default::Maybe{String} = nothing
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing

    function Argument(name, type, vararg, require, default, description, line)
        require = vararg ? false : require # force require=false for vararg
        new(name, type, vararg, require, default, description, line)
    end
end

"""
    struct Option <: ComoniconExpr

type for options, e.g `--option=<value>` or `-o<value>`.

# Fields

- `sym::Symbol`: symbol of the option in Julia program.
- `name::String`: name of the option in shell, by default
    this is the same as `sym` but will replace `_` with `-`.
- `hint::Maybe{String}`: hint message of this option, default is `nothing`.
- `require::Bool`: if this option is required, default is `false`.
- `type`: type of the option value, default is `Any`.
- `short::Bool`: if the option support short option syntax (`-o<value>` syntax), default is `false`.
- `description::Description`: description of this option, default is `Description()`.
- `line::Maybe{LineNumberNode}`: line number of this option in Julia scripts.
"""
Base.@kwdef struct Option <: ComoniconExpr
    sym::Symbol
    name::String = replace(string(sym), '_' => '-')
    hint::Maybe{String} = nothing
    require::Bool = false # unless option doesn't have a default keyword
    type = Any
    short::Bool = false
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing
end

"""
    struct Flag <: ComoniconExpr

Type for flag in CLI, e.g `--flag` or `-f`.

# Fields

- `sym`: the symbol in Julia programs.
- `name::String`: name of the flag, default is the same as `sym` but will replace `_` with `-`.
- `short::Bool`: if this flag support short flag syntax e.g `-f`, default is `false`.
- `description::Description`: description of this flag, default is `Description()`.
- `line::Maybe{LineNumberNode}`: the line number of this flag object in original Julia program.

# Constructors

```julia
Flag(fields_above...)
Flag(;fields_above...)
```
"""
Base.@kwdef struct Flag <: ComoniconExpr
    sym::Symbol
    name::String = replace(string(sym), '_' => '-')
    short::Bool = false
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing
end

"""
    struct NodeCommand <: ComoniconExpr

Type for node command in a CLI, these command
are only used to dispatch the actual command in CLI,
and must have sub-command, e.g

```shell
main-cmd node-cmd leaf-cmd 1 2 3
```

# Fields

- `name::String`: name of the command.
- `subcmds::Dict{String, Any}`: sub-commands of the node command,
    this is a `name=>command` dict, the command should be either
    `NodeCommand` or [`LeafCommand`](@ref).
- `description::Description`: description of this node command, default is `Description()`.
- `line::Maybe{LineNumberNode}`: line number of the node command in its original Julia program, default is `nothing`.

# Constructors

```julia
NodeCommand(fields_above...)
NodeCommand(;fields_above...)
```
"""
Base.@kwdef struct NodeCommand <: ComoniconExpr
    name::String
    subcmds::Dict{String,Any}
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing

    function NodeCommand(name, subcmds, description, line)
        !isempty(subcmds) || error("list of subcommands should not be empty")
        new(name, subcmds, description, line)
    end
end

"""
    struct LeafCommand <: ComoniconExpr

Type for a leaf command in CLI. A leaf command
is the command that actually execute the program
e.g

```shell
main-cmd node-cmd leaf-cmd 1 2 3
```

# Fields

- `fn`: a Julia callable that executes the command.
- `name::String`: name of the command.
- `args::Vector{Argument}`: list of CLI arguments, see [`Argument`](@ref), default is `Argument[]`.
- `nrequire::Int`: number of required arguments, default is the number of `require==true` arugments in `args`.
- `vararg::Maybe{Argument}`: variant argument, default is `nothing`.
- `flags::Dict{String, Flag}`: map between flag name and flag object, see [`Flag`](@ref), default is the empty collection.
- `options::Dict{String, Option}`: map between option name and option object, see [`Option`](@ref), default is the empty collection.
- `description::Description`: description of the leaf command, default is `Description()`.
- `line::Maybe{LineNumberNode}`: line number of the leaf command in original Julia program.

# Constructors

```julia
LeafCommand(fields_above...)
LeafCommand(;fields_above...)
```
"""
Base.@kwdef struct LeafCommand <: ComoniconExpr
    fn::Any
    name::String
    args::Vector{Argument} = Argument[]
    nrequire::Int = count(x -> x.require, args)
    vararg::Maybe{Argument} = nothing
    flags::Dict{String,Flag} = Dict{String,Flag}()
    options::Dict{String,Option} = Dict{String,Option}()
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing

    function LeafCommand(fn, name, arg, nrequire, vararg, flags, options, description, line)

        isnothing(vararg) ||
            vararg.vararg == true ||
            error("expect vararg $(vararg.name) " * "to have property vararg=true")
        new(fn, name, arg, nrequire, vararg, flags, options, description, line)
    end
end

"""
    struct Entry <: ComoniconExpr

Top-level entry of the CLI.

# Fields

- `root::Union{NodeCommand,LeafCommand}`: the entry command.
- `version::Maybe{VersionNumber}`: version number of the command.
- `line::Maybe{LineNumberNode}`: line number of the original Julia program.

# Constructors

```julia
Entry(fields_above...)
Entry(;fields_above...)
```
"""
Base.@kwdef struct Entry <: ComoniconExpr
    root::Union{NodeCommand,LeafCommand}
    version::Maybe{VersionNumber} = nothing
    line::Maybe{LineNumberNode} = nothing
end
