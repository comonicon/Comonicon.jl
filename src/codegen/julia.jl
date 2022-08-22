module JuliaExpr

using ..AST
using ..Comonicon: CommandException, CommandExit, _sprint
using ExproniconLite
using Configurations: Configurations

function help_str(x; color = true, width::Int)
    _sprint(print_cmd, x; color, displaysize = (24, width))
end

Base.@kwdef struct Configs
    color::Bool = true
    static::Bool = true
    width::Int = 120
    dash::Bool = true
    plugin::Bool = false
end

Base.@kwdef struct EmitContext
    entry::Entry
    configs::Configs
end

function print_help_str(x, ctx::EmitContext)
    color = ctx.configs.color
    if ctx.entry.root === x # print entry docstring
        x = ctx.entry
    end

    if ctx.configs.static
        :($Base.print($(help_str(x; color, ctx.configs.width))))
    else
        :($print_cmd(IOContext(stdout, :color => $color), $x))
    end
end

# printing in expression
emit_help(x, ctx::EmitContext, ptr::Int = 1; color = true) = quote
    if !isnothing(findnext(isequal("-h"), ARGS, $ptr)) ||
       !isnothing(findnext(isequal("--help"), ARGS, $ptr))
        $(print_help_str(x, ctx))
        return 0
    end
end

function emit_error(cmd, ctx::EmitContext, msg::String; color::Bool = true)
    msg = "Error: $msg, use -h or --help to check more detailed help info"
    return quote
        printstyled($msg; color = :red, bold = true)
        println()
        $(print_help_str(cmd, ctx))
        println()
        return 1
    end
end

function emit_error(cmd, ctx::EmitContext, msg::Expr; color::Bool = true)
    msg.head === :string || throw(Meta.ParseError("expect string expression, got $msg"))

    ex = Expr(:string, "Error: ")
    for each in msg.args
        if each isa Number
            push!(ex.args, string(each))
        else
            push!(ex.args, each)
        end
    end
    push!(ex.args, ", use -h or --help to check more detailed help info")
    return quote
        printstyled($msg; color = :red, bold = true)
        println()
        $(print_help_str(cmd, ctx))
        println()
        return 1
    end
end

"""
    emit(cmd::Entry[, ptr::Int=1])

Emit `Expr` from a `Entry`.
"""
function emit(cmd::Entry, configs::Configs = Configs(), ptr::Int = 1)
    jlfn = JLFunction(;
        name = :command_main,
        args = [Expr(:kw, :(ARGS::Vector{String}), :ARGS)],
        body = quote
            $(emit_scan_version(cmd))
            $(configs.plugin ? emit_plugin_lookup(cmd) : nothing)
            $(emit_body(cmd.root, EmitContext(cmd, configs), ptr))
        end,
    )
    return codegen_ast(jlfn)
end

function emit_scan_version(cmd::Entry)
    quote
        if "--version" in ARGS
            println($(cmd.version))
            return 0
        end
    end
end

function emit_plugin_lookup(cmd::Entry)
    quote
        if length(ARGS) ≥ 1
            path = Sys.which(cmd.root.name * "-" * ARGS[1])
            path === nothing && @goto no_plugin_found

            p = run(ignorestatus(`$path $(ARGS[2:end])`))
            return p.exitcode
        end
        @label no_plugin_found
    end
end

function emit_body(cmd::NodeCommand, ctx::EmitContext, ptr::Int = 1)
    nargs_assert = quote
        if length(ARGS) < $ptr
            $(emit_error(
                cmd,
                ctx,
                "valid sub-commands for command $(cmd.name) are: $(join(keys(cmd.subcmds), ", "))",
            ))
        end
    end

    jl = JLIfElse()
    for (name, subcmd) in cmd.subcmds
        jl[:(ARGS[$ptr] == $name)] = emit_body(subcmd, ctx, ptr + 1)
    end
    jl.otherwise = emit_error(cmd, ctx, :("Error: unknown command $(ARGS[$ptr])"))
    return quote
        if length(ARGS) == $ptr && (ARGS[$(ptr)] == "-h" || ARGS[$(ptr)] == "--help")
            $(print_help_str(cmd, ctx))
            return 0
        end

        $nargs_assert
        $(codegen_ast(jl))
    end
end

function emit_body(cmd::LeafCommand, ctx::EmitContext, ptr::Int = 1)
    @gensym idx

    ctx.configs.dash && return quote
        $(emit_help(cmd, ctx, ptr))

        $idx = findnext(isequal("--"), ARGS, $ptr)
        if isnothing($idx) # no dash
            $(emit_norm_body(cmd, ctx, ptr))
        else # dash
            $(emit_dash_body(cmd, ctx, idx, ptr))
        end
    end

    # no dash
    return quote
        $(emit_help(cmd, ctx, ptr))
        $(emit_norm_body(cmd, ctx, ptr))
    end
end

"""
emit dash parsing code (contains `--`).
"""
function emit_dash_body(cmd::LeafCommand, ctx::EmitContext, idx::Symbol, ptr::Int = 1)
    @gensym token token_ptr args kwargs

    quote # parse option/flag
        $kwargs = Dict{Symbol, Any}()
        $token_ptr = $ptr
        while $token_ptr ≤ $idx - 1
            $token = ARGS[$token_ptr]
            if startswith($token, "-")
                $(emit_kwarg(cmd, ctx, token, kwargs, token_ptr))
            else
                $(emit_error(cmd, ctx, :("unknown command: $($token)")))
            end
            $token_ptr += 1
        end

        $args = ARGS[$idx+1:end]
        $(emit_leaf_call(cmd, ctx, args, kwargs))
    end
end

"""
emit the normal parsing code (do not contain dash `--`)
"""
function emit_norm_body(cmd::LeafCommand, ctx::EmitContext, ptr::Int = 1)
    @gensym token_ptr args kwargs token

    quote
        $args = []
        $kwargs = Dict{Symbol, Any}()
        sizehint!($args, $(cmd.nrequire))
        $token_ptr = $ptr
        while $token_ptr ≤ length(ARGS)
            $token = ARGS[$token_ptr]
            if startswith($token, "-")
                $(emit_kwarg(cmd, ctx, token, kwargs, token_ptr))
            else # argument
                push!($args, $token)
            end
            $token_ptr += 1
        end

        $(emit_leaf_call(cmd, ctx, args, kwargs))
    end
end

function emit_leaf_call(cmd::LeafCommand, ctx::EmitContext, args::Symbol, kwargs::Symbol)
    @gensym nargs
    ret = quote
        $nargs = length($args)
    end

    if cmd.nrequire > 0
        push!(
            ret.args,
            quote
                if $(cmd.nrequire) > $nargs
                    $(emit_error(cmd, ctx, "expect $(cmd.nrequire) positional arguments"))
                end
            end,
        )
    end

    # check maximum number of arguments
    if isnothing(cmd.vararg)
        push!(
            ret.args,
            quote
                if $(length(cmd.args)) < $nargs
                    $(emit_error(
                        cmd,
                        ctx,
                        "expect at most $(length(cmd.args)) positional arguments",
                    ))
                end
            end,
        )
    end

    if !isempty(cmd.options)
        # check if all required options are filled
        for each in values(cmd.options)
            each.require || continue
            err_hint = "--" * each.name

            if each.short
                err_hint *= ",-" * each.name[1:1]
            end

            err_hint = "expect option $err_hint"

            @gensym idx
            push!(ret.args, quote
                if !($(QuoteNode(each.sym)) in Base.keys($kwargs))
                    $(emit_error(cmd, ctx, err_hint))
                end
            end)
        end

        # convert dict to option types
        # NOTE: since the types must be an option type
        # thus the corresponding program depends on Configurations
        # already, we are safe to depend on it in the generated code
        for option in values(cmd.options)
            Configurations.is_option(option.type) || continue
            push!(ret.args, quote
                $kwargs[$(QuoteNode(option.sym))] =
                    $Configurations.from_dict($(option.type), $kwargs[$(QuoteNode(option.sym))])
            end)
        end
    end

    call = Expr(:call, cmd.fn)
    if !isempty(cmd.flags) || !isempty(cmd.options)
        push!(call.args, Expr(:parameters, :($kwargs...)))
    end

    for (i, arg) in enumerate(cmd.args)
        arg.require || break
        push!(call.args, emit_parse_value(cmd, ctx, arg.type, :($args[$i])))
    end

    ifelse = JLIfElse()
    ifelse[:($nargs == $(cmd.nrequire))] = quote
        $(emit_exception_handle(cmd, ctx, call))
        return 0
    end

    for i in cmd.nrequire+1:length(cmd.args)
        call = copy(call)
        type = cmd.args[i].type
        push!(call.args, emit_parse_value(cmd, ctx, type, :($args[$i])))
        ifelse[:($nargs == $i)] = quote
            $(emit_exception_handle(cmd, ctx, call))
            return 0
        end
    end

    if isnothing(cmd.vararg)
        ifelse.otherwise =
            emit_error(cmd, ctx, "expect at most $(length(cmd.args)) positional arguments")
    else
        @gensym varargs
        call = copy(call)
        push!(call.args, :($varargs...))
        type = cmd.vararg.type
        if type === Any || type === String || type === AbstractString
            ifelse.otherwise = quote
                $varargs = $args[$(length(cmd.args))+1:end]
                $(emit_exception_handle(cmd, ctx, call))
                return 0
            end
        else
            ifelse.otherwise = quote
                $varargs = map($args[$(length(cmd.args) + 1):end]) do value
                    $(emit_parse_value(cmd, ctx, type, :value))
                end
                $(emit_exception_handle(cmd, ctx, call))
                return 0
            end
        end
    end

    push!(ret.args, codegen_ast(ifelse))
    return ret
end

function emit_exception_handle(cmd::LeafCommand, ctx::EmitContext, call, color::Bool = true)
    quote
        try
            $call
        catch e
            # NOTE:
            # terminate should return 0
            # other exception will return exitcode
            if e isa $CommandExit
                println("command exit with 0")
                return 0
            elseif e isa $CommandException
                showerror(stdout, e)
                println()
                $(print_help_str(cmd, ctx))
                println()
                return e.exitcode
            else
                rethrow(e)
            end
        end
    end
end

function emit_kwarg(cmd::LeafCommand, ctx::EmitContext, token::Symbol, kwargs::Symbol, token_ptr)
    if isempty(cmd.flags) && isempty(cmd.options)
        return emit_error(cmd, ctx, :("do not have $($token)"))
    end

    @gensym sym key value

    ifelse = JLIfElse()
    # long option/flag
    ifelse[:(startswith($token, "--"))] = quote
        $key = lstrip(split($token, '='; limit=2)[1], '-')
        $key = split($key, '.'; limit=2)[1]
        $(emit_long_option_or_flag(cmd, ctx, token, kwargs, sym, key, value, token_ptr))
    end

    # short option
    ifelse.otherwise = quote
        $key = $token[2:2]
        $(emit_short_flag_or_option(cmd, ctx, token, sym, key, value, token_ptr))
    end

    return quote
        $(codegen_ast(ifelse))
        $kwargs[$sym] = $value
    end
end

function emit_short_flag_or_option(
    cmd::LeafCommand,
    ctx::EmitContext,
    token::Symbol,
    sym::Symbol,
    key::Symbol,
    value::Symbol,
    token_ptr,
)
    ifelse = JLIfElse()
    for (_, flag) in cmd.flags
        if flag.short
            name = flag.name[1:1]
            ifelse[:($key == $name)] = quote
                $sym = $(QuoteNode(flag.sym))
                $value = true
            end
        end
    end
    ifelse.otherwise = emit_short_option(cmd, ctx, token, sym, key, value, token_ptr)
    return codegen_ast(ifelse)
end

function emit_short_option(
    cmd::LeafCommand,
    ctx::EmitContext,
    token::Symbol,
    sym::Symbol,
    key::Symbol,
    value::Symbol,
    token_ptr,
)
    ifelse = JLIfElse()
    for (_, option) in cmd.options
        if option.short
            name = option.name[1:1]
            ifelse[:($key == $name)] = quote
                if occursin('=', $token)
                    _, $value = split($token, '='; limit=2)
                elseif length($token) == 2 # read next
                    $token_ptr += 1
                    if $token_ptr > length(ARGS)
                        $(emit_error(option, ctx, "expect a value"))
                    end
                    $value = ARGS[$token_ptr]
                else # -o<value>
                    $value = $token[3:end]
                end
                $sym = $(QuoteNode(option.sym))
                $value = $(emit_parse_value(option, ctx, option.type, value))
            end
        end
    end
    ifelse.otherwise = emit_error(
        cmd, ctx, :("cannot find short flag or option: $($token)")
    )
    return codegen_ast(ifelse)
end

function emit_long_option_or_flag(
    cmd::LeafCommand,
    ctx::EmitContext,
    token::Symbol,
    kwargs::Symbol,
    sym::Symbol,
    key::Symbol,
    value::Symbol,
    token_ptr,
)

    ifelse = JLIfElse()
    for (name, flag) in cmd.flags
        ifelse[:($key == $name)] = quote
            $sym = $(QuoteNode(flag.sym))
            $value = true
        end
    end

    for (name, option) in cmd.options
        ifelse[:($key == $name)] = quote
            $sym = $(QuoteNode(option.sym))
            $(emit_option(option, ctx, token, kwargs, value, token_ptr))
        end
    end

    ifelse.otherwise = emit_error(cmd, ctx, :("cannot find $($token)"))
    return codegen_ast(ifelse)
end

function emit_parse_value(cmd, ctx::EmitContext, type, value)
    if type === Any || type === AbstractString
        return value
    elseif type === String # we need to convert SubString to String
        return :(String($value))
    elseif Configurations.is_option(type)
        return :($TOML.parsefile($value))
    else
        @gensym ret
        return quote
            $ret = tryparse($type, $value) # this may calls the runtime in Comonicon.Arg
            if isnothing($ret)
                $(emit_error(cmd, ctx, "expect value of type: $(type)"))
            end
            $ret
        end
    end
end

function emit_option(
    option::Option,
    ctx::EmitContext,
    token::Symbol,
    kwargs::Symbol,
    value::Symbol,
    token_ptr::Symbol,
)
    if Configurations.is_option(option.type)
        return emit_option_with_option_type(option, ctx, token, kwargs, value, token_ptr)
    end

    return quote
        if occursin('=', $token)
            _, $value = split($token, '='; limit=2)
        else # read next token
            $token_ptr += 1
            if $token_ptr > length(ARGS)
                $(emit_error(option, ctx, "expect a value"))
            end
            $value = ARGS[$token_ptr]
        end
        $value = $(emit_parse_value(option, ctx, option.type, value))
    end
end

function emit_option_with_option_type(
    option::Option,
    ctx::EmitContext,
    token::Symbol,
    kwargs::Symbol,
    value::Symbol,
    token_ptr::Symbol,
)

    @gensym key field_value fields
    assign_field_to_dict = foreach_leaf_field(option.type, value, fields) do dict_ex, type
        quote
            $field_value = $(emit_parse_value(option, ctx, type, field_value))
            $dict_ex = $field_value 
        end
    end
    assign_field_to_dict.otherwise = emit_error(option, ctx, :("cannot find field $($fields)"))

    return quote
        if occursin('=', $token)
            $key, $field_value = split($token, '='; limit=2)
            if occursin('.', $key)
                _, $fields = split($key, '.'; limit=2)
            else
                $fields = nothing
            end
        else # read next token
            if occursin('.', $token)
                _, $fields = split($token, '.'; limit=2)
            else
                $fields = nothing
            end

            $token_ptr += 1
            if $token_ptr > length(ARGS)
                $(emit_error(option, ctx, "expect a value"))
            end
            $field_value = ARGS[$token_ptr]
        end

        if isnothing($fields) # path to the config file
            $value = $(emit_parse_value(option, ctx, option.type, field_value))
        else
            $value = get(Dict{String, Any}, $kwargs, $(QuoteNode(option.sym)))
            $(codegen_ast(assign_field_to_dict))
        end
    end
end

function foreach_leaf_field!(f, jl::JLIfElse, ::Type{T}, dict, fields::Symbol, prefix::String="") where T
    Configurations.foreach_keywords(T) do name, type
        key = isempty(prefix) ? string(name) : join((prefix, name), '.')
        dict_ex = :($dict[$(string(name))])
        if Configurations.is_option(type)
            foreach_leaf_field!(jl, type, dict_ex, fields, key) do dict_ex, type
                quote
                    Base.get!(Dict{String, Any}, $dict, $(string(name)))
                    $(f(dict_ex, type))
                end
            end
        else
            jl[:($fields == $key)] = quote
                $(f(dict_ex, type))
            end
        end
    end
    return jl
end

function foreach_leaf_field(f, ::Type{T}, dict::Symbol, fields::Symbol) where T
    return foreach_leaf_field!(f, JLIfElse(), T, dict, fields)
end

end # JuliaExpr
