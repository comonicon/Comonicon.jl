const Maybe{T} = Union{Nothing,T}

abstract type ComoniconExpr end

Base.@kwdef struct Description <: ComoniconExpr
    brief::Union{Nothing,String} = nothing
    content::Union{Nothing,String} = nothing
end

Base.convert(::Type{Description}, ::Nothing) = Description()
Base.convert(::Type{Description}, x::String) = Description(x)
Base.convert(::Type{Description}, x::AbstractString) = Description(String(x))

Description(::Nothing) = Description(nothing, nothing)
function Description(text::String)
    return Description(brief(text), text)
end

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

Base.@kwdef struct Option <: ComoniconExpr
    sym::Symbol
    name::String = replace(string(sym), '_' => '-')
    hint::Maybe{String} = nothing
    type = Any
    short::Bool = false
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing
end

Base.@kwdef struct Flag <: ComoniconExpr
    sym::Symbol
    name::String = replace(string(sym), '_' => '-')
    short::Bool = false
    description::Description = Description()
    line::Maybe{LineNumberNode} = nothing
end

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

Base.@kwdef struct Entry <: ComoniconExpr
    root::Union{NodeCommand,LeafCommand}
    version::Maybe{VersionNumber} = nothing
    line::Maybe{LineNumberNode} = nothing
    options::Maybe{Configs.Comonicon} = nothing
end

Entry(root, version, line) = Entry(root, version, line, nothing)