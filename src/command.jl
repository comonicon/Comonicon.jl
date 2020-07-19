const MAX_DOC_WIDTH = 28
const INDENT = 2

abstract type AbstractCommand end

Base.@kwdef struct Arg
    name::String = "argument"
    doc::String = "positional argument"
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
    version::VersionNumber = v"0.1.0"
end

Base.@kwdef struct NodeCommand <: AbstractCommand
    name::String
    subcmds::Vector{Any}
    doc::String = ""
end

struct LeafCommand <: AbstractCommand
    entry # a callable
    name::String
    args::Vector{Arg}
    options::Vector{Option}
    flags::Vector{Flag}
    doc::String

    function LeafCommand(entry, name, args, options, flags, doc)
        check_duplicate_short_options(options, flags)
        new(entry, name, args, options, flags, doc)
    end
end

Arg(name; kwargs...) = Arg(;name=name, kwargs...)
Option(name, arg=Arg(); kwargs...) = Option(;name=name, arg=arg, kwargs...)
Flag(name; kwargs...) = Flag(;name=name, kwargs...)
EntryCommand(root; kwargs...) = EntryCommand(;root=root, kwargs...)
NodeCommand(name, cmds; doc="") = NodeCommand(;name=name, subcmds=cmds, doc=doc)

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

function Base.show(io::IO, cmd::NodeCommand)
    printstyled(io, cmd_name(cmd); color=:light_blue, bold=true)
    printstyled(io, " <command>", color=:light_blue)
end

function Base.show(io::IO, entry::EntryCommand)
    printstyled(io, cmd_name(entry); color=:light_blue, bold=true)
    print(io, " ", entry.version)
end

function Base.show(io::IO, cmd::LeafCommand)
    printstyled(io, cmd_name(cmd); color=:light_blue, bold=true)

    if !isempty(cmd.options)
        printstyled(io, " [options...]"; color=:light_cyan)
    end

    if !isempty(cmd.flags)
        printstyled(io, " [flags...]"; color=:light_cyan)
    end

    if !isempty(cmd.args)
        print(io, " ")
        join(io, cmd.args, " ")
    end
end

function Base.show(io::IO, opt::Option)
    if opt.short
        printstyled(io, "-", first(opt.name), ", "; color=:light_cyan)
    end
    printstyled(io, "--", opt.name; color=:light_cyan)
    print(io, " ", opt.arg)
end

function Base.show(io::IO, opt::Flag)
    if opt.short
        printstyled(io, "-", first(opt.name); color=:light_cyan)
    end
    printstyled(io, ",--", opt.name; color=:light_cyan)
end

function Base.show(io::IO, arg::Arg)
    if arg.type === Any
        printstyled(io, "<", arg.name, ">", color=:light_magenta)
    else
        printstyled(io, "<", arg.name, "::", arg.type, ">", color=:light_magenta)
    end
end


print_cmd(x) = print_cmd(stdout, x)

function print_cmd(io::IO, cmd::EntryCommand)
    print_title(io, cmd)

    print_section(io, "Usage")
    println(io, " "^INDENT, cmd.root, "\n")
    print_body(io, cmd.root)
end

function print_cmd(io::IO, cmd::NodeCommand)
    if get(io, :inline, false)
        doc_indent = get_doc_indent(io, cmd)
        indent = get(io, :indent, 0)
        print(io, " "^indent, cmd, " "^doc_indent, cmd_doc(cmd))
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, cmd::LeafCommand)
    if get(io, :inline, false)
        doc_indent = get_doc_indent(io, cmd)
        indent = get(io, :indent, 0)
        print(io, " "^indent, cmd, " "^doc_indent, cmd_doc(cmd))
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, x::Union{Option, Flag})
    doc_indent = get_doc_indent(io, x)
    print(io, " "^get(io, :indent, 0), x, " "^doc_indent, cmd_doc(x))
end

function print_cmd(io::IO, x::Arg)
    doc_indent = get_doc_indent(io, x)
    print(io, " "^get(io, :indent, 0), x, " "^doc_indent, cmd_doc(x))
end

function scan_indent(x::NodeCommand, min_indent=4)
    indent = min_indent
    for cmd in x.subcmds
        indent = max(indent, length(string(cmd)) + min_indent)
    end
    return indent
end

function scan_indent(x::LeafCommand, min_indent=4)
    indent = min_indent
    for arg in x.args
        indent = max(indent, length(string(arg)) + min_indent)
    end

    for opt in x.options
        indent = max(indent, length(string(opt)) + min_indent)
    end

    for flag in x.flags
        indent = max(indent, length(string(flag)) + min_indent)
    end
    return indent
end

function get_doc_indent(io::IO, x)
    doc_indent = get(io, :doc_indent, -1)
    return doc_indent > 0 ? doc_indent - length(string(x)) : 4
end

function wrap_io(io::IO, x)
    return IOContext(io, :indent=>INDENT, :doc_indent=>scan_indent(x), :inline=>true)
end

function print_title(io::IO, x)
    println(io)
    println(io, "  ", x)
    println(io)
    println(io, cmd_doc(x))
    println(io)
end

function print_body(io::IO, cmd::NodeCommand)
    io = wrap_io(io, cmd)
    print_list(io, "Commands", cmd.subcmds)
end

function print_body(io::IO, cmd::LeafCommand)
    io = wrap_io(io, cmd)
    if !isempty(cmd.args)
        print_list(io, "Args", cmd.args)
    end

    if !isempty(cmd.flags)
        print_list(io, "Flags", cmd.flags)
    end

    if !isempty(cmd.options)
        print_list(io, "Options", cmd.options)
    end
end

function print_section(io::IO, sec)
    printstyled(io, sec; bold=true)
    print(io, "\n\n")
end

function print_list(io::IO, title, list)
    print_section(io, title)
    for x in list
        print_cmd(io, x)
        println(io)
    end
    println(io)
end
