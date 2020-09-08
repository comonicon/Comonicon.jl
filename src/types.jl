module Types

# types
export Arg, Option, Flag, EntryCommand, NodeCommand, LeafCommand, AbstractCommand

# interfaces
export print_cmd,
    cmd_doc, cmd_name, cmd_sym, set_brief_length!, max_brief_length, check_first_sentence_length

const MAX_DOC_WIDTH = 28
const INDENT = 2
const HELP_FLAG = "-h, --help"
const VERSION_FLAG = "-V, --version"
const HELP_FLAG_DOC = "print this help message"
const VERSION_FLAG_DOC = "print version information"
const PRESERVED = ["h", "help"]
const MAX_BRIEF_LENGTH = Ref{Int}(80)

"""
    set_brief_length!(n::Int=120)

Set the maximum length of a brief description. Default is 120.

!!! note

    This is only effective when called before [`@main`](@ref) or [`codegen`](@ref).
"""
function set_brief_length!(n::Int = 120)
    MAX_BRIEF_LENGTH[] = n
end

"""
    max_brief_length()

Get the maximum length allowed for a brief description.
"""
max_brief_length() = MAX_BRIEF_LENGTH[]

"""
    AbstractCommand

abstract type for commands.
"""
abstract type AbstractCommand end

struct CommandDoc
    first::String
    rest::String

    function CommandDoc(name::String, lineinfo::LineNumberNode, doc::String)
        doc = strip(doc)
        brief = check_first_sentence_length(name, lineinfo, doc)
        new(brief, doc[length(brief)+1:end])
    end

    function CommandDoc()
        new("", "")
    end
end

function Base.iterate(doc::CommandDoc, st = 1)
    if st == 1
        return doc.first, 2
    elseif st == 2
        return doc.rest, 3
    else
        return nothing
    end
end

function Base.show(io::IO, doc::CommandDoc)
    print(io, doc.first, doc.rest)
end

Base.@kwdef struct Arg
    name::String = "arg"
    line::LineNumberNode = LineNumberNode(0)
    doc::CommandDoc = CommandDoc(name, line, "positional argument")
    require::Bool = true
    vararg::Bool = false
    type = Any
    default::Union{String, Nothing} = nothing
end

function Arg(name::String, line::LineNumberNode, doc::String, require::Bool, vararg::Bool, type, default)
    Arg(name, line, CommandDoc(name, line, doc), require, vararg, type, default)
end

Base.@kwdef struct Option
    name::String
    line::LineNumberNode = LineNumberNode(0)
    doc::CommandDoc = CommandDoc()
    arg::Arg = Arg()
    short::Bool = false
end

function Option(name::String, line::LineNumberNode, doc::String, arg::Arg, short::Bool)
    Option(name, line, CommandDoc(name, line, doc), arg, short)
end

Base.@kwdef struct Flag
    name::String
    line::LineNumberNode = LineNumberNode(0)
    doc::CommandDoc = CommandDoc()
    short::Bool = true
end

function Flag(name::String, line::LineNumberNode, doc::String, short::Bool)
    Flag(name, line, CommandDoc(name, line, doc), short)
end

"""
    EntryCommand <: AbstractCommand

`EntryCommand` describes the entry of the CLI. It contains
an actual root command (either [`LeafCommand`](@ref) or [`NodeCommand`](@ref))
of the entire CLI and a version number. The version number is `v"0.0.0"` by default.
"""
Base.@kwdef struct EntryCommand <: AbstractCommand
    root::Any
    version::VersionNumber = v"0.0.0"
    line::LineNumberNode = LineNumberNode(0)
end

"""
    NodeCommand <: AbstractCommand

`NodeCommand` describes the command in the middle of a CLI, e.g
in the following `remote` is a `NodeCommand`, it will dispatch
the call to its sub-command `show`. See also [`LeafCommand`](@ref).

```sh
git remote show origin
```
"""
Base.@kwdef struct NodeCommand <: AbstractCommand
    name::String
    line::LineNumberNode = LineNumberNode(0)
    doc::CommandDoc = CommandDoc()
    subcmds::Vector{Any}
end

function NodeCommand(name::String, line::LineNumberNode, doc::String, subcmds::Vector)
    NodeCommand(name, line, CommandDoc(name, line, doc), subcmds)
end

function NodeCommand(name::String, subcmds::Vector; kwargs...)
    NodeCommand(; name = name, subcmds = subcmds, kwargs...)
end

"""
    LeafCommand <: AbstractCommand

`LeafCommand` describes the command at the end of a CLI, e.g
in the following `show` is `LeafCommand`, it is the command
that actually executes things. See also [`NodeCommand`](@ref).

```sh
git remote show origin
```
"""
struct LeafCommand <: AbstractCommand
    entry::Any # a callable
    name::String
    args::Vector{Arg}
    nrequire::Int
    options::Vector{Option}
    flags::Vector{Flag}
    doc::CommandDoc
    line::LineNumberNode

    function LeafCommand(entry, name, args, options, flags, doc, line)
        check_duplicate_short_options(options, flags)
        check_varargs_position(args)
        nrequire = check_required_args(args)
        new(entry, name, args, nrequire, options, flags, doc, line)
    end
end

function LeafCommand(entry, name, args, options, flags, doc::String, line)
    LeafCommand(entry, name, args, options, flags, CommandDoc(name, line, doc), line)
end

Arg(name; kwargs...) = Arg(; name = name, kwargs...)
Option(name, arg = Arg(); kwargs...) = Option(; name = name, arg = arg, kwargs...)
Flag(name; kwargs...) = Flag(; name = name, kwargs...)
EntryCommand(root; kwargs...) = EntryCommand(; root = root, kwargs...)

function LeafCommand(
    entry;
    name::String = string(nameof(entry)),
    args::Vector{Arg} = Arg[],
    options::Vector{Option} = Option[],
    flags::Vector{Flag} = Flag[],
    doc = CommandDoc(),
    line::LineNumberNode = LineNumberNode(0),
)

    LeafCommand(entry, name, args, options, flags, doc, line)
end

cmd_name(cmd::EntryCommand) = cmd_name(cmd.root)
cmd_name(cmd) = cmd.name

cmd_doc(cmd::EntryCommand) = cmd_doc(cmd.root)
cmd_doc(cmd) = cmd.doc

cmd_sym(cmd) = Symbol(cmd_name(cmd))
cmd_lineinfo(cmd) = cmd.line
# Printings

print_option_or_flag(io::IO, xs...) = printstyled(io, xs...; color = :light_cyan)
print_args(io::IO, xs...) = printstyled(io, xs...; color = :light_magenta)


"""
    print_cmd([io, ]cmd)

Print a command object. This is used to generate command help.
"""
function print_cmd end

function Base.show(io::IO, cmd::NodeCommand)
    printstyled(io, cmd_name(cmd); color = :light_blue, bold = true)
    printstyled(io, " <command>", color = :light_blue)
end

function Base.show(io::IO, entry::EntryCommand)
    printstyled(io, cmd_name(entry); color = :light_blue, bold = true)

    if entry.version > v"0.0.0"
        print(io, " v", entry.version)
    end
end

function Base.show(io::IO, cmd::LeafCommand)
    printstyled(io, cmd_name(cmd); color = :light_blue, bold = true)

    if !isempty(cmd.options)
        printstyled(io, " [options]"; color = :light_cyan)
    end

    if !isempty(cmd.flags)
        printstyled(io, " [flags]"; color = :light_cyan)
    end

    if !isempty(cmd.args)
        print(io, " ")
        join(io, cmd.args, " ")
    end
end

function Base.show(io::IO, opt::Option)
    if opt.short
        print_option_or_flag(io, "-", first(opt.name), ", ")
    end
    print_option_or_flag(io, "--", opt.name)
    print(io, " ", opt.arg)
end

function Base.show(io::IO, opt::Flag)
    if opt.short
        print_option_or_flag(io, "-", first(opt.name), ", ")
    end
    print_option_or_flag(io, "--", opt.name)
end

function Base.show(io::IO, arg::Arg)
    notation = get(io, :notation, true)
    show_notation = notation && !arg.require
    show_notation && print_args(io, "[")

    if ignore_type(arg.type)
        print_args(io, "<", arg.name, ">")
    else
        print_args(io, "<", arg.name, "::", arg.type, ">")
    end

    show_notation && print_args(io, "]")
end

ignore_type(type) = type in [Any, String] || type <: AbstractString

print_cmd(x) = print_cmd(stdout, x)

function print_cmd(io::IO, cmd::EntryCommand)
    print_title(io, cmd)

    print_section(io, "Usage")
    println(io, " "^INDENT, cmd.root, "\n")
    print_body(io, cmd.root, true)
end

function print_cmd(io::IO, cmd::NodeCommand)
    if get(io, :inline, false)
        partition(io, cmd, cmd_doc(cmd).first)
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, cmd::LeafCommand)
    if get(io, :inline, false)
        partition(io, cmd, cmd_doc(cmd).first)
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, x::Union{Option,Flag})
    partition(io, x, cmd_doc(x)...)
end

function print_cmd(io::IO, x::Arg)
    if x.require
        partition(io, x, cmd_doc(x)...)
    else
        partition(io, x, "optional argument. ", cmd_doc(x)...)
    end
end

function print_help(io::IO)
    doc_indent = first_line_doc_indent(io, HELP_FLAG)
    print(io, " "^get(io, :indent, 0))
    print_option_or_flag(io, HELP_FLAG)
    print(io, " "^doc_indent, HELP_FLAG_DOC, "\n\n")
end

function print_version(io::IO)
    doc_indent = first_line_doc_indent(io, VERSION_FLAG)
    print(io, " "^get(io, :indent, 0))
    print_option_or_flag(io, VERSION_FLAG)
    print(io, " "^doc_indent, VERSION_FLAG_DOC, "\n\n")
end

function partition(io, cmd, xs...; width = get(io, :terminal_width, 80))
    doc_indent = get(io, :doc_indent, -1)
    doc_width = width - doc_indent
    first_line_indent = first_line_doc_indent(io, cmd)
    indent = " "^get(io, :indent, 0)
    print(io, indent, cmd)
    doc = join(xs)
    isempty(doc) && return

    print_doc(io, cmd, doc, doc_width, first_line_indent, indent, doc_indent)
end

# only ommit the description if they can be displayed in full later
function print_doc(
    io::IO,
    cmd::AbstractCommand,
    doc::String,
    width::Int,
    first_line_indent::Int,
    indent::String,
    doc_indent::Int,
)
    brief = first_sentence(doc)
    lines = splitlines(brief, width)
    print(io, " "^first_line_indent, first(lines))

    for i in 2:min(3, length(lines))
        print(io, "\n", indent, " "^doc_indent, lines[i])
    end

    if length(lines) > 3
        print(io, "...")
    end
end

function print_doc(
    io::IO,
    cmd,
    doc::String,
    width::Int,
    first_line_indent::Int,
    indent::String,
    doc_indent::Int,
)
    lines = splitlines(doc, width)
    print(io, " "^first_line_indent, first(lines))
    for i in 2:length(lines)
        print(io, "\n", indent, " "^doc_indent, lines[i])
    end
end

function first_sentence(content)
    index = findfirst(". ", content)

    if index === nothing
        return content
    else
        return content[1:first(index)]
    end
end

"""
    splittext(s)

Split the text in string `s` into an array, but keep all the separators
attached to the preceding word.

!!! note

    this is copied from Luxor/text.jl
"""
function splittext(s::String)
    # split text into array, keeping all separators
    # hyphens stay with first word
    result = Array{String,1}()
    iobuffer = IOBuffer()
    for c in s
        if isspace(c)
            push!(result, String(take!(iobuffer)))
            iobuffer = IOBuffer()
        elseif c == '-' # hyphen splits words but needs keeping
            print(iobuffer, c)
            push!(result, String(take!(iobuffer)))
            iobuffer = IOBuffer()
        else
            print(iobuffer, c)
        end
    end
    push!(result, String(take!(iobuffer)))
    return result
end

function splitlines(s, width = 80)
    words = splittext(s)
    lines = String[]
    current_line = String[]
    space_left = width
    for word in words
        word == "" && continue
        word_width = length(word)

        if space_left < word_width
            # start a new line
            push!(lines, strip(join(current_line)))
            current_line = String[word]
            space_left = width
        elseif endswith(word, "-")
            push!(current_line, word)
            space_left -= word_width
        else
            push!(current_line, word * " ")
            space_left -= word_width + 1
        end
    end
    isempty(current_line) || push!(lines, strip(join(current_line)))
    return lines
end


function scan_indent(x::NodeCommand, min_indent = 4)
    indent = min_indent
    indent = max(indent, length(HELP_FLAG) + min_indent)
    indent = max(indent, length(VERSION_FLAG) + min_indent)

    for cmd in x.subcmds
        indent = max(indent, length(string(cmd)) + min_indent)
    end
    return indent
end

function scan_indent(x::LeafCommand, min_indent = 4)
    indent = min_indent
    indent = max(indent, length(HELP_FLAG) + min_indent)
    indent = max(indent, length(VERSION_FLAG) + min_indent)

    for arg in x.args
        arg_str = sprint(print, arg; context = :notation => false)
        indent = max(indent, length(arg_str) + min_indent)
    end

    for opt in x.options
        indent = max(indent, length(string(opt)) + min_indent)
    end

    for flag in x.flags
        indent = max(indent, length(string(flag)) + min_indent)
    end
    return indent
end

function first_line_doc_indent(io::IO, x)
    doc_indent = get(io, :doc_indent, -1)
    notation = get(io, :notation, true)
    x_str = sprint(print, x; context = :notation => notation)
    return doc_indent > 0 ? doc_indent - length(x_str) : 4
end

function wrap_io(io::IO, x, notation = true)
    return IOContext(
        io,
        :indent => INDENT,
        :doc_indent => scan_indent(x),
        :inline => true,
        :notation => notation,
    )
end

function print_title(io::IO, x)
    println(io)
    println(io, "  ", x)
    println(io)
    println(io, cmd_doc(x))
    println(io)
end

function print_body(io::IO, cmd::NodeCommand, isentry = false)
    io = wrap_io(io, cmd)
    print_list(io, "Commands", cmd.subcmds)

    print_section(io, "Flags")
    print_help(io)
    isentry && print_version(io)
    println(io)
end

function print_body(io::IO, cmd::LeafCommand, isentry = false)
    io = wrap_io(io, cmd, false)
    if !isempty(cmd.args)
        print_list(io, "Args", cmd.args)
    end

    if !isempty(cmd.options)
        print_list(io, "Options", cmd.options)
    end

    if !isempty(cmd.flags)
        print_list(io, "Flags", cmd.flags)
        print_help(io)
        isentry && print_version(io)
    else
        print_section(io, "Flags")
        print_help(io)
        isentry && print_version(io)
    end

    println(io)
end

function print_section(io::IO, sec)
    printstyled(io, sec; bold = true)
    print(io, "\n\n")
end

function print_list(io::IO, title, list)
    print_section(io, title)

    for x in sort(list; by = x -> first(cmd_name(x)))
        print_cmd(io, x)
        print(io, "\n\n")
    end
end

# validate
function check_duplicate_short_options(options, flags)
    flags_and_options = Iterators.flatten((options, flags))

    for cmd in flags_and_options
        if cmd_name(cmd) in PRESERVED
            error("$cmd is preserved")
        end

        n_duplicate = count(flags_and_options) do x
            cmd_name(x) == cmd_name(cmd)
        end

        if n_duplicate > 1
            error("$cmd is duplicated, found $n_duplicate")
        end

        if cmd.short
            first_letter = string(first(cmd_name(cmd)))
            if first_letter in PRESERVED
                error("$cmd cannot use short version since -$first_letter is preserved.")
            end

            n_duplicate = count(flags_and_options) do x
                x.short && string(first(cmd_name(x))) == first_letter
            end

            if n_duplicate > 1
                error("the short version of $cmd is duplicated, $n_duplicate found")
            end
        end
    end
    return
end

function check_required_args(args)
    count = 0
    prev_require = 0
    for (i, arg) in enumerate(args)
        if arg.require && !(arg.vararg)
            prev_require + 1 == i || error("optional positional arguments must occur at the end")
            count += 1
            prev_require = i
        end
    end

    return count
end

function check_varargs_position(args)
    first_vararg_position = 0
    first_vararg = nothing
    for (i, arg) in enumerate(args)
        if arg.vararg
            first_vararg_position = i
            break
        end
    end
    if first_vararg_position > 0 && first_vararg_position != length(args)
        throw(Meta.ParseError("syntax: invalid \"...\" on non-final argument around $(first_vararg.line)"))
    end
    return
end

function check_first_sentence_length(name, lineinfo, doc)
    brief = first_sentence(doc)
    if length(brief) > max_brief_length()
        error(
            "the first sentence of doc should not be larger than $(max_brief_length()). ",
            "please revise the doc string for [$name] at $(lineinfo.file):$(lineinfo.line)",
        )
    end
    return brief
end

end # module
