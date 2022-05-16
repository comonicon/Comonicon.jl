tab(n::Int) = " "^n
ignore_type(type) = type in [Any, String] || type <: AbstractString

function has_args(cmd::LeafCommand)
    !isempty(cmd.args) || !isnothing(cmd.vararg)
end

section(io) = print(io, "\n\n")
function section(io::IO, title)
    section(io)
    printstyled(io, title; bold = true)
    section(io)
end

Base.@kwdef mutable struct Indent
    text::Int = 0
    desc::Int = 0
end

Base.@kwdef mutable struct Color
    name::Symbol = :light_blue
    args::Symbol = :light_magenta
    dash::Symbol = :light_cyan
end

Base.@kwdef mutable struct Terminal
    width::Int = max(displaysize(stdout)[2], 80) # always have a minimum size
    left::Int = floor(Int, 0.4 * width) # left column max width
    right::Int = floor(Int, 0.5 * width) # right column max width

    color::Color = Color()
    indent::Indent = Indent()

    brief::Bool = true
end

Base.show(io::IO, ::MIME"text/plain", cmd::ComoniconExpr) = print_cmd(io, cmd)

function Base.show(io::IO, ::MIME"text/plain", cmd::Description)
    printstyled(io, "brief:\n"; color = :light_black)
    println(io, cmd.brief)
    printstyled(io, "content:\n"; color = :light_black)
    print(io, cmd.content)
end

print_cmd(cmd) = print_cmd(stdout, cmd)
print_cmd(io::IO, cmd) =
    print_cmd(io, cmd, Terminal(width = get(io, :displaysize, displaysize(io))[2]))
print_cmd(cmd, t::Terminal) = print_cmd(stdout, cmd, t)

function print_cmd(io::IO, arg::Argument, t::Terminal)
    color = t.color.args
    arg.require || printstyled(io, "["; color)
    arg.require && printstyled(io, "<"; color)
    printstyled(io, arg.name; color)
    if !ignore_type(arg.type)
        printstyled(io, "::", arg.type; color)
    end
    arg.vararg && printstyled(io, "..."; color)
    arg.require && printstyled(io, ">"; color)
    arg.require || printstyled(io, "]"; color)
    return
end

print_cmd(io::IO, cmd::Flag, t::Terminal) = _print_dash(io, cmd, t)

function print_cmd(io::IO, cmd::Option, t::Terminal)
    _print_dash(io, cmd, t)
    isnothing(cmd.hint) || printstyled(io, tab(1), "<", cmd.hint, ">"; color = t.color.args)
    return
end

function _print_dash(io::IO, cmd::Union{Option,Flag}, t::Terminal)
    color = t.color.dash
    if cmd.short
        printstyled(io, "-", first(cmd.name), ", "; color)
    end
    printstyled(io, "--", cmd.name; color)
end

function print_content(io::IO, desc::Description, t::Terminal)
    isnothing(desc.content) || print_within(io, desc.content, t.width, 0)
    # if Intro section is empty, use brief description
    isnothing(desc.brief) || print_within(io, desc.brief, t.width, 0)
    return
end

function print_cmd(io::IO, cmd::Entry, t::Terminal)
    section(io)
    printstyled(io, tab(2), cmd.root.name; color = t.color.name, bold = true)
    isnothing(cmd.version) || print(io, " v", cmd.version)
    section(io)
    t.brief = false
    # print description ahead
    print_content(io, cmd.root.description, t)
    section(io, "Usage")
    print_head(io, cmd, t)
    print_body(io, cmd, t)
end

function print_cmd(io::IO, cmd::NodeCommand, t::Terminal)
    section(io)
    print_head(io, cmd, t)
    section(io)
    print_content(io, cmd.description, t)
    print_body(io, cmd, t)
end

function print_cmd(io::IO, cmd::LeafCommand, t::Terminal)
    section(io)
    print_head(io, cmd, t)
    section(io)
    print_content(io, cmd.description, t)
    print_body(io, cmd, t)
end

print_head(io::IO, cmd::Entry, t::Terminal) = print_head(io, cmd.root, t)

function print_head(io::IO, cmd::NodeCommand, t::Terminal)
    print(io, tab(2))
    print_signature(io, cmd, t)
end

function print_head(io::IO, cmd::LeafCommand, t::Terminal)
    print(io, tab(2))
    print_name(io, cmd, t)
    if has_args(cmd)
        printstyled(io, tab(1), "<args>"; color = t.color.args)
    end

    isempty(cmd.args) || printstyled(io, tab(1), "[options]"; color = t.color.dash)
    isempty(cmd.flags) || printstyled(io, tab(1), "[flags]"; color = t.color.dash)
    return
end

function print_name(io::IO, cmd, t::Terminal)
    printstyled(io, cmd.name; color = t.color.name, bold = true)
end

function print_signature(io::IO, cmd, t::Terminal)
    print_cmd(io, cmd, t)
end

function print_signature(io::IO, cmd::NodeCommand, t::Terminal)
    print_name(io, cmd, t)
    printstyled(io, tab(1), "<command>"; color = t.color.name)
end

function print_signature(io::IO, cmd::LeafCommand, t::Terminal)
    print_name(io, cmd, t)
    for each in cmd.args
        print(io, tab(1))
        print_cmd(io, each, t)
    end

    if !isnothing(cmd.vararg)
        print(io, tab(1))
        print_cmd(io, cmd.vararg, t)
    end
end

function print_body(io::IO, cmd::Entry, t::Terminal)
    print_body(io, cmd.root, t)
    version_flag = "-V, --version"
    printstyled(io, tab(2), version_flag; color = t.color.dash)
    print_indent_content(io, "Print version", t, length(version_flag) + 2)
    println(io)
end

function print_body(io::IO, cmd::NodeCommand, t::Terminal)
    section(io, "Commands")
    for each in values(cmd.subcmds)
        print_name_brief(io, each, t)
        section(io)
    end
    section(io, "Flags")
    print_help(io, t)
    return
end

function print_body(io::IO, cmd::LeafCommand, t::Terminal)
    if has_args(cmd)
        section(io, "Args")
    end

    for each in cmd.args
        print_sig_brief(io, each, t)
        section(io)
    end

    if !isnothing(cmd.vararg)
        print_sig_brief(io, cmd.vararg, t)
        section(io)
    end

    if !isempty(cmd.options)
        section(io, "Options")
        for each in unique(values(cmd.options))
            print_sig_brief(io, each, t)
            section(io)
        end
    end

    section(io, "Flags")

    for each in unique(values(cmd.flags))
        print_sig_brief(io, each, t)
        section(io)
    end
    print_help(io, t)
end

function print_help(io::IO, t::Terminal)
    help_flag = "-h, --help"
    printstyled(io, tab(2), help_flag; color = t.color.dash)
    print_indent_content(io, "Print this help message", t, length(help_flag) + 2)
    println(io)
end

function print_sig_brief(io::IO, cmd, t::Terminal)
    print_with_brief(print_signature, io, cmd, t)
end

function print_name_brief(io::IO, cmd, t::Terminal)
    print_with_brief(print_name, io, cmd, t)
end

function print_with_brief(f, io::IO, cmd, t::Terminal)
    buf = IOBuffer()
    f(buf, cmd, t)
    s = String(take!(buf))

    middle = t.width - t.left - t.right
    firstline = length(s) + 2
    t.left - firstline + middle > 0 || error(
        "signature of $(cmd.name) is too long, consider " *
        "set `command.width` in `Comonicon.toml` to " *
        "larger value, or truncate your argument and command name length " *
        "current terminal width is $(t.width)",
    )

    print(io, tab(2))
    f(io, cmd, t)

    if isnothing(cmd.description.brief)
        isnothing(cmd.description.content) && return
        brief = content_brief(cmd.description.content; max_width = t.right)
    else
        brief = cmd.description.brief
    end
    print_indent_content(io, brief, t, firstline)
    return
end

function print_indent_content(io::IO, text::String, t::Terminal, firstline::Int)
    middle = t.width - t.left - t.right
    lines = splitlines(text, t.right)
    isempty(lines) && return
    print(io, tab(t.left - firstline + middle), lines[1])
    length(lines) > 1 && println(io)
    for i in 2:length(lines)
        print(io, tab(t.width - t.right), lines[i])
        if i !== lastindex(lines)
            println(io)
        end
    end
    return
end

function print_within(io::IO, text::String, width::Int, indent::Int)
    lines = splitlines(text, width - indent)
    for i in eachindex(lines)
        print(io, tab(indent), lines[i])
        if i !== lastindex(lines)
            println(io)
        end
    end
end
