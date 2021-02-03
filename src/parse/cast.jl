const CACHE_FLAG = Ref{Bool}(true)

"""
    enable_cache()

Enable command compile cache. See also [`disable_cache`](@ref).
"""
function enable_cache()
    CACHE_FLAG[] = true
    return
end

"""
    disable_cache()

Disable command compile cache. See also [`enable_cache`](@ref).
"""
function disable_cache()
    CACHE_FLAG[] = false
    return
end

"""
    @cast <function expr>
    @cast <module expr>
    @cast <function name>
    @cast <module name>

Cast a Julia object to a command object. `@cast` will
always execute the given expression, and only create and
register an command object via [`command`](@ref) after
analysing the given expression.

# Example

The most basic way is to use `@cast` on a function as your command
entry.

```julia
@cast function your_command(arg1, arg2::Int)
    # your processing code
end
```

This will create a [`LeafCommand`](@ref) object and register it
to the current module's `CASTED_COMMANDS` constant. You can access
this object via `MODULE_NAME.CASTED_COMMANDS["your_command"]`.

Note this will not create a functional CLI, to create a function
CLI you need to create an entry point, which can be declared by
[`@main`](@ref).
"""
macro cast(ex)
    if CACHE_FLAG[] && iscached()
        return esc(ex)
    else
        return esc(cast_m(__module__, QuoteNode(__source__), ex))
    end
end

function cast_m(m::Module, line::QuoteNode, ex)
    ret = Expr(:block)
    pushmaybe!(ret, create_casted_commands(m))

    if ex isa Symbol
        push!(ret.args, parse_module(m, line, ex))
        return ret
    end

    def = splitdef(ex; throw = false)
    if def === nothing
        push!(ret.args, parse_module(m, line, ex))
        return ret
    end

    push!(ret.args, parse_function(m, line, ex, def))
    return ret
end

function parse_function(m::Module, line::QuoteNode, ex, def)
    haskey(def, :name) || error("command entry cannot be annoymous")
    def[:name] isa Symbol || error("command name should be a Symbol")

    return quote
        $ex
        Core.@__doc__ $(def[:name])
        $(xcall(
            set_cmd!,
            casted_commands(m),
            xcall(command, def[:name], parse_args(def), parse_kwargs(def); line = line),
        ))
    end
end

function parse_module(m::Module, line::QuoteNode, ex::Expr)
    ex.head === :module ||
        throw(Meta.ParseError("invalid expression, can only cast functions or modules"))

    return quote
        $ex
        $(xcall(set_cmd!, casted_commands(m), xcall(command, ex.args[2]; line = line)))
    end
end

function parse_module(m::Module, line::QuoteNode, ex::Symbol)
    return xcall(set_cmd!, casted_commands(m), xcall(command, ex; line = line))
end

function parse_args(def)
    types = Expr(:vect)
    haskey(def, :args) || return types

    # (name, type, require)
    for each in def[:args]
        push!(types.args, Expr(:tuple, to_argument(def, each)...))
    end
    return types
end

function parse_kwargs(def)
    types = Expr(:vect)
    haskey(def, :kwargs) || return types

    # (name, type, isflag)
    for each in def[:kwargs]
        push!(types.args, Expr(:tuple, to_option_or_flag(each)...))
    end
    return types
end

function to_argument(def, ex)
    # (name, type, require, vararg, default_value)
    @smatch ex begin
        ::Symbol => (string(ex), Any, true, false, nothing)
        :($name::$type) => (string(name), wrap_type(def, type), true, false, nothing)
        :($name::$type...) => (string(name), wrap_type(def, type), true, true, nothing)
        Expr(:kw, :($name::$type), value) =>
            (string(name), wrap_type(def, type), false, false, repr(value))
        :($name...) => (string(name), Any, true, true, nothing)
        Expr(:kw, name::Symbol, value) => (string(name), Any, false, false, repr(value))
        _ => throw(Meta.ParseError("invalid syntax for command line entry: $ex"))
    end
end

function to_option_or_flag(ex)
    @smatch ex begin
        Expr(:kw, name::Symbol, value) => (string(name), Any, false, repr(value))
        Expr(:kw, :($name::Bool), false) => (string(name), Bool, true, false)
        Expr(:kw, :($name::$type), value) => (string(name), type, false, repr(value))
        Expr(:kw, :($name::Bool), true) => throw(
            Meta.ParseError(
                "Boolean options must use false as default value, and will be parsed as flags. got $name",
            ),
        )
        ::Symbol || :($name::$type) => throw(
            Meta.ParseError("options should have default values or make it a positional argument"),
        )
        _ => throw(Meta.ParseError("invalid syntax: $ex"))
    end
end

function wrap_type(def, type)
    if haskey(def, :whereparams)
        return Expr(:where, type, def[:whereparams]...)
    else
        return type
    end
end

function create_casted_commands(m)
    if isdefined(m, :CASTED_COMMANDS)
        return
    else
        return :(const CASTED_COMMANDS = Dict{String,Any}())
    end
end

casted_commands(m) = GlobalRef(m, :CASTED_COMMANDS)

# Entry
"""
    @main <function expr>
    @main

Create an `EntryCommand` and use it as the entry of the entire CLI.
If you only have one function to cast to a CLI, you can use `@main`
instead of `@cast` so it will create both the command object and
the entry.
"""
macro main(xs...)
    return esc(main_m(__module__, QuoteNode(__source__), xs...))
end

# @main <expr>
function main_m(m::Module, line::QuoteNode, ex::Expr)
    if CACHE_FLAG[] && iscached()
        return quote
            Core.@__doc__ $ex
            include($(cachefile()[1]))
        end
    end

    ret = Expr(:block)
    def = splitdef(ex; throw = false)
    var_cmd, var_entry = gensym(:cmd), gensym(:entry)
    push!(ret.args, ex)

    if def === nothing
        ex.head === :(=) && return create_entry(m, line, ex)
        ex.head === :module ||
            throw(Meta.ParseError("invalid expression, can only cast functions or modules"))
        cmd = xcall(command, ex.args[2]; line = line)
        push!(ret.args, :($var_cmd = $cmd))
    else
        push!(ret.args, :(Core.@__doc__ $(def[:name])))
        cmd = xcall(command, def[:name], parse_args(def), parse_kwargs(def); line = line)
        push!(ret.args, :($var_cmd = $cmd))
    end

    push!(ret.args, :($var_entry = $(xcall(Types, :EntryCommand, var_cmd; version = get_version(m)))))
    push!(ret.args, precompile_or_exec(m, var_entry))
    return ret
end

# @main <symbol>
function main_m(m::Module, line::QuoteNode, ex::Symbol)
    CACHE_FLAG[] && iscached() && return :(include($(cachefile()[1])))
    var_cmd, var_entry = gensym(:cmd), gensym(:entry)
    quote
        $var_cmd = $(xcall(command, ex; line = line))
        $var_entry = $(xcall(Types, :EntryCommand, var_cmd; line = line))
        $(precompile_or_exec(m, var_entry))
    end
end

# @main
function main_m(m::Module, line::QuoteNode)
    CACHE_FLAG[] && iscached() && return :(include($(cachefile()[1])))
    return create_entry(m, line)
end

function create_entry(m::Module, line::QuoteNode)
    if m === Main
        # in scripts
        if endswith(Base.PROGRAM_FILE, ".jl")
            # normal julia scripts
            name = Base.PROGRAM_FILE[1:end-3]
        elseif isempty(Base.PROGRAM_FILE)
            # scripts without a program file
            name = "main"
        else
            # scripts with shebang
            name = Base.PROGRAM_FILE
        end
        options = nothing
    else
        # in projects
        options = read_configs(m)
        name = options.name
    end

    ret = Expr(:block)
    push!(ret.args, :(Core.@__doc__ const COMMAND_ENTRY_DOC_STUB = nothing))

    var_cmd, var_entry = gensym(:cmd), gensym(:entry)
    cmd = xcall(
        Types,
        :NodeCommand,
        name,
        line,
        :($to_string(@doc(COMMAND_ENTRY_DOC_STUB))),
        :(collect(values($m.CASTED_COMMANDS))),
    )
    entry = xcall(Types, :EntryCommand, var_cmd, options, get_version(m), line)

    push!(ret.args, :($var_cmd = $cmd))
    push!(ret.args, :($var_entry = $entry))
    push!(ret.args, precompile_or_exec(m, var_entry))
    return ret
end

function precompile_or_exec(m::Module, entry)
    if m == Main && CACHE_FLAG[]
        return quote
            $create_cache($entry)
            include($(cachefile()[1]))
        end
    elseif m == Main
        return quote
            $(xcall(m, :eval, xcall(CodeGen, :codegen, entry)))
            command_main()
        end
    else
        quote
            $(create_casted_commands(m))
            $(xcall(set_cmd!, casted_commands(m), entry, "main"))
            $(xcall(m, :eval, xcall(CodeGen, :codegen, entry)))

            """
                comonicon_install(;kwargs...)

            Install the CLI manually. This will use the default configuration in `Comonicon.toml`,
            if it exists. See also [`comonicon_build`](@ref). For more detailed reference, please
            refer to [Comonicon documentation](https://rogerluo.me/Comonicon.jl/).
            """
            comonicon_install(; kwargs...) = $(GlobalRef(Comonicon, :install))($m; kwargs...)

            """
                comonicon_install_path([quiet=false])

            Install the `PATH` and `FPATH` to your shell configuration file. You can use `comonicon_install_path(true)`,
            to skip interactive prompt.
            For more detailed reference, please refer to [Comonicon documentation](https://rogerluo.me/Comonicon.jl/).
            """
            comonicon_install_path() = $(GlobalRef(Comonicon.BuildTools, :install_env_path))()

            # entry point for apps
            function julia_main()::Cint
                try
                    return command_main()
                catch
                    Base.invokelatest(Base.display_error, Base.catch_stack())
                    return 1
                end
            end

            precompile(Tuple{typeof($m.command_main),Array{String,1}})
        end
    end
end
