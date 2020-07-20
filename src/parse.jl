# macro cast(ex)
# end

# macro main()
# end

# @cast function foo(x)

# end

# @cast module Goo
#     @cast sin(x) = x
#     @cast cos(x) = x
# end

macro cast(ex)
    esc(cast_m(__module__, "", ex))
end

macro cast(alias::String, ex)
    esc(cast_m(__module__, alias, ex))
end

macro command_main(xs...)
    if __module__ == Main
        return esc(command_main_m(__module__, xs...))
    else
        return quote
            $(command_main_m(__module__, xs...))

            precompile(Tuple{typeof($($__module__).command_main), Array{String, 1}})
        end |> esc
    end
end

_version_number(x::String) = VersionNumber(x)
_version_number(x::VersionNumber) = x

function command_main_m(m, kwargs...)
    if !isempty(kwargs)
        ex = first(kwargs)
        def = splitdef(ex; throw=false)
        if def !== nothing
            ret = Expr(:block)
            push!(ret.args, ex)
            push!(ret.args, :(Core.@__doc__ $(def[:name])))
        
            args_types, kwargs_types = parse_command!(ret, m, def, ex)
        
            push!(ret.args, :(Base.eval($m, codegen(EntryCommand(command($(def[:name]), $args_types, $kwargs_types))))))
            return ret
        end
    end

    configs = Dict{Symbol, Any}(:name=>default_name(m), :version=>get_version(m), :doc=>"")
    for kw in kwargs
        kw isa Expr && kw.head == :(=) || throw(ParseError("expect keyword argument"))

        for key in [:name, :version, :doc]
            if kw.args[1] === key
                configs[key] = kw.args[2]
            end
        end
    end

    if isdefined(m, :CASTED_COMMANDS)
        cmd = NodeCommand(configs[:name], collect(values(m.CASTED_COMMANDS)), configs[:doc])
        return codegen(EntryCommand(cmd; version=_version_number(configs[:version])))
    end

    throw(Meta.ParseError("define commands using @cast first"))
end

function set_cmd!(cmds::Dict, cmd)
    name = cmd_name(cmd)
    if haskey(cmds, name)
        @warn "replacing command $name in the registry"
    end

    return cmds[name] = cmd
end

default_name(x) = lowercase(string(nameof(x)))

function cast_m(m, alias::String, ex)
    ret = Expr(:block)
    if !isdefined(m, :CASTED_COMMANDS)
        # create registry
        push!(ret.args, :(const CASTED_COMMANDS = Dict{String, Any}()))
    end

    casted_commands = GlobalRef(m, :CASTED_COMMANDS)

    if ex isa Symbol
        push!(ret.args, Snippet.call(set_cmd!, casted_commands, xcommand(ex; name=alias)))
        return ret
    end

    def = splitdef(ex; throw=false)

    if def === nothing # not a function
        if ex.head === :module
            push!(ret.args, ex)
            push!(ret.args, Snippet.call(set_cmd!, casted_commands, xcommand(ex.args[2]; name=alias)))
            return ret
        else
            throw(ParseError("invalid syntax $ex"))
        end
    end

    push!(ret.args, ex)
    push!(ret.args, :(Base.@__doc__ $(def[:name])))

    args_types, kwargs_types = parse_command!(ret, m, def, ex)

    push!(ret.args, quote
        $casted_commands[$(string(def[:name]))] = $(xcommand(def[:name], args_types, kwargs_types; name=alias))
    end)
    return ret
end

function parse_command!(ret, m, def, ex)
    haskey(def, :name) || error("command entry cannot be annoymous")
    def[:name] isa Symbol || error("command name should be a Symbol")
    !isdefined(m, def[:name]) || error("command entry cannot be overloaded")

    # create command
    ## scan argument types
    args_types = gensym(:types)
    push!(ret.args, :($args_types = $(scan_args_types(def))))
    kwargs_types = gensym(:types)
    push!(ret.args, :($kwargs_types = $(scan_kwargs_types(def))))
    return args_types, kwargs_types
end

function scan_args_types(def)
    types = Expr(:vect)
    haskey(def, :args) || return types

    # (name, type, require)
    for each in def[:args]
        push!(types.args, Expr(:tuple, parse_arg(def, each)...))
    end
    return types
end

function parse_arg(def, arg)
    if arg isa Symbol
        return string(arg), Any, true
    elseif arg.head === :(::)
        return string(arg.args[1]), wrap_type(def, arg.args[2]), true
    elseif arg.head === :kw
        name, T, _ = parse_arg(def, arg.args[1])
        return name, T, false
    else
        throw(Meta.ParseError("invalid syntax for command line entry: $arg"))
    end
end

function scan_kwargs_types(def)
    types = Expr(:vect)
    haskey(def, :kwargs) || return types

    # (name, type, short)
    for each in def[:kwargs]
        if each isa Symbol
            throw(Meta.ParseError("options should have default values or make it a positional argument"))
        elseif each.head === :kw
            name = each.args[1]
            if name isa Symbol
                push!(types.args, Expr(:tuple, string(name), Any, false))
            elseif name.head === :(::)
                # `Bool` kwarg must use false as default
                # and will be treated as flags
                if (name.args[2] === :Bool)
                    if each.args[2] == false
                        push!(types.args, Expr(:tuple, string(name.args[1]), Bool, true))
                    else
                        msg = "Boolean options must use false as default value, and will be parsed as flags. got $name"
                        throw(Meta.ParseError(msg))
                    end
                else
                    T = wrap_type(def, name.args[2])
                    push!(types.args, Expr(:tuple, string(name.args[1]), T, false))
                end
            end
        elseif each.head === :(::)
            name = each.args[1]
            if name isa Symbol
                T = wrap_type(def, name.args[2])
                push!(types.args, Expr(:tuple, string(name), T, false))
            else
                throw(Meta.ParseError("invalid command entry syntax $name"))
            end
        end
    end
    return types
end

function wrap_type(def, type)
    if haskey(def, :whereparams)
        return Expr(:where, type, def[:whereparams]...)
    else
        return type
    end
end

# module runtime parsing
function command(m::Module; name="", doc=docstring(m))    
    if isempty(name) # force to have a valid name
        name = default_name(m)
    end
    NodeCommand(name, collect(values(m.CASTED_COMMANDS)), doc)
end

function command(f::Function, args, kwargs; name="")
    if isempty(name) # force to have a valid name
        name = default_name(f)
    end

    md = Base.Docs.doc(f)
    intro, doc_args, option_docs, flag_docs = parse_doc(md)
    args = create_args(args, doc_args)
    options, flags = create_options_and_flags(kwargs, option_docs, flag_docs)
    LeafCommand(f; name=name, args=args, options=options, flags=flags, doc=intro)
end

function docstring(x)
    return sprint(Base.Docs.doc(x); context=:color=>true) do io, x
        show(io, MIME"text/plain"(), x)
    end
end

create_args(args, docs) = [Arg(name; type=type, require=require, doc=get(docs, name, "")) for (name, type, require) in args]

function create_options_and_flags(kwargs, option_docs, flag_docs)
    options = Option[]
    flags = Flag[]
    for (name, type, short) in kwargs
        if haskey(option_docs, name)
            arg, doc, doc_short = option_docs[name]
            push!(options, Option(name, Arg(arg; type=type), doc, doc_short || short))
        elseif haskey(flag_docs, name)
            doc, doc_short = flag_docs[name]
            push!(flags, Flag(name, doc, doc_short || short))
        else
            # by default, short options are flags
            if short
                push!(flags, Flag(name; short=short))
            else
                push!(options, Option(name, Arg("::$type"; type=type); short=short))
            end
        end
    end
    return options, flags
end
