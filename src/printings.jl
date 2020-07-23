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
        printstyled(io, " [options...]"; color = :light_cyan)
    end

    if !isempty(cmd.flags)
        printstyled(io, " [flags...]"; color = :light_cyan)
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
        print_option_or_flag(io, "-", first(opt.name))
    end
    print_option_or_flag(io, ",--", opt.name)
end

function Base.show(io::IO, arg::Arg)
    notation = get(io, :notation, true)
    show_notation = notation && !arg.require
    show_notation && print_args(io, "[")

    if arg.type in [Any, String] || arg.type <: AbstractString
        print_args(io, "<", arg.name, ">")
    else
        print_args(io, "<", arg.name, "::", arg.type, ">")
    end

    show_notation && print_args(io, "]")
end

print_cmd(x) = print_cmd(stdout, x)

function print_cmd(io::IO, cmd::EntryCommand)
    print_title(io, cmd)

    print_section(io, "Usage")
    println(io, " "^INDENT, cmd.root, "\n")
    print_body(io, cmd.root, true)
end

function print_cmd(io::IO, cmd::NodeCommand)
    if get(io, :inline, false)
        partition(io, cmd, cmd_doc(cmd))
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, cmd::LeafCommand)
    if get(io, :inline, false)
        partition(io, cmd, cmd_doc(cmd))
    else
        print_title(io, cmd)
        print_body(io, cmd)
    end
end

function print_cmd(io::IO, x::Union{Option,Flag})
    partition(io, x, cmd_doc(x))
end

function print_cmd(io::IO, x::Arg)
    if x.require
        partition(io, x, cmd_doc(x))
    else
        partition(io, x, "optional argument. ", cmd_doc(x))
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

function partition(io, cmd, xs...; width = 80)
    doc_indent = get(io, :doc_indent, -1)
    doc_width = width - doc_indent
    first_line_indent = first_line_doc_indent(io, cmd)
    indent = " "^get(io, :indent, 0)
    print(io, indent, cmd)
    doc = join(xs)
    isempty(doc) && return

    lines = splitlines(doc, doc_width)

    print(io, " "^first_line_indent, first(lines))
    for i in 2:length(lines)
        print(io, "\n", indent, " "^doc_indent, lines[i])
    end
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

    if !isempty(cmd.flags)
        print_list(io, "Flags", cmd.flags)
        print_help(io)
        isentry && print_version(io)
    else
        print_section(io, "Flags")
        print_help(io)
        isentry && print_version(io)
    end

    if !isempty(cmd.options)
        print_list(io, "Options", cmd.options)
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
