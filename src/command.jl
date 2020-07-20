const MAX_DOC_WIDTH = 28
const INDENT = 2
const HELP_FLAG = "-h, --help"
const VERSION_FLAG = "-V, --version"
const HELP_FLAG_DOC = "print this help message"
const VERSION_FLAG_DOC = "print version information"

print_option_or_flag(io::IO, xs...) = printstyled(io, xs...; color=:light_cyan)
print_args(io::IO, xs...) = printstyled(io, xs...; color=:light_magenta)

abstract type AbstractCommand end

Base.@kwdef struct Arg
    name::String = "argument"
    doc::String = "positional argument"
    require::Bool = true
    type = Any
end

Base.@kwdef struct Option
    name::String
    arg::Arg = Arg()
    doc::String = ""
    short::Bool = false
end

Base.@kwdef struct Flag
    name::String
    doc::String = ""
    short::Bool = true
end

Base.@kwdef struct EntryCommand <: AbstractCommand
    root
    version::VersionNumber = v"0.0.0"
end

struct NodeCommand <: AbstractCommand
    name::String
    subcmds::Vector{Any}
    doc::String

    function NodeCommand(name, subcmds, doc)
        new(name, subcmds, strip(doc))
    end
end

struct LeafCommand <: AbstractCommand
    entry # a callable
    name::String
    args::Vector{Arg}
    nrequire::Int
    options::Vector{Option}
    flags::Vector{Flag}
    doc::String

    function LeafCommand(entry, name, args, options, flags, doc)
        check_duplicate_short_options(options, flags)
        nrequire = check_required_args(args)
        new(entry, name, args, nrequire, options, flags, strip(doc))
    end
end

Arg(name; kwargs...) = Arg(;name=name, kwargs...)
Option(name, arg=Arg(); kwargs...) = Option(;name=name, arg=arg, kwargs...)
Flag(name; kwargs...) = Flag(;name=name, kwargs...)
EntryCommand(root; kwargs...) = EntryCommand(;root=root, kwargs...)
NodeCommand(name, cmds; doc="") = NodeCommand(name, cmds, doc)
NodeCommand(;name, cmds, doc="") = NodeCommand(name, cmds, doc)

function LeafCommand(;entry,
        name::String=string(nameof(entry)),
        args::Vector{Arg} = Arg[],
        options::Vector{Option} = Option[],
        flags::Vector{Flag} = Flag[], doc::String = "")

    LeafCommand(entry, name, args, options, flags, doc)
end

LeafCommand(f; kwargs...) = LeafCommand(;entry=f, kwargs...)

cmd_name(cmd::EntryCommand) = cmd_name(cmd.root)
cmd_name(cmd::NodeCommand) = cmd.name
cmd_name(cmd::LeafCommand) = cmd.name
cmd_name(x::Option) = x.name
cmd_name(x::Flag) = x.name

cmd_doc(cmd::EntryCommand) = cmd_doc(cmd.root)
cmd_doc(cmd::AbstractCommand) = cmd.doc

cmd_doc(cmd::Option) = cmd.doc
cmd_doc(cmd::Flag) = cmd.doc
cmd_doc(cmd::Arg) = cmd.doc

