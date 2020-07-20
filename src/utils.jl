regex_flag(x) = Regex("^--$(cmd_name(x))\$")
short_regex_flag(x) = Regex("^-$(first(cmd_name(x)))\$")

function rm_lineinfo(ex)
    if ex isa Expr
        args = []
        for each in ex.args
            if !(each isa LineNumberNode)
                push!(args, rm_lineinfo(each))
            end
        end
        return Expr(ex.head, args...)
    else
        return ex
    end
end

function get_version(m::Module)
    # project module
    path = pathof(m)
    if path !== nothing
        envpath = joinpath(dirname(path), "..")
        project = Pkg.Types.read_project(Pkg.Types.projectfile_path(envpath))
        if project.name == string(nameof(m)) && project.version !== nothing
            return project.version
        end
    end

    if hasproperty(m, :COMMAND_VERSION)
        return m.COMMAND_VERSION
    end
    return v"0.0.0"
end

module Snippet

using ..Comonicon

function call(m::Module, name::Union{Symbol, Expr}, xs...; kwargs...)
    if isempty(kwargs)
        return Expr(:call, GlobalRef(m, name), xs...)
    else
        params = Expr(:parameters)
        for (key, value) in kwargs
            push!(params.args, Expr(:kw, key, value))
        end

        return Expr(:call, GlobalRef(m, name), params, xs...)
    end
end

function call(m::Module, name, xs...; kwargs...)
    call(m, nameof(name), xs...; kwargs...)
end

call(name, xs...; kwargs...) = call(Comonicon, name, xs...; kwargs...)

end

xcommand(xs...; kwargs...) = Snippet.call(:command, xs...; kwargs...)

cachefile(m::Module) = joinpath(dirname(pathof(m)), "comonicon.cmd.jl")

function iscached(m::Module)
    return ispath(cachefile(m))
end

function nrequired_args(args::Vector)
    return count(args) do x
        x.require == true
    end
end

function all_required(args::Vector)
    return all(args) do x
        x.require == true
    end
end

all_required(cmd::LeafCommand) = all_required(cmd.args)


"""
    splittext(s)

Split the text in string `s` into an array, but keep all the separators
attached to the preceding word.

!!! note

    this is copied from Luxor/text.jl
"""
function splittext(s)
    # split text into array, keeping all separators
    # hyphens stay with first word
    result = Array{String, 1}()
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

function splitlines(s, width=80)
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
            current_line = String[]
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