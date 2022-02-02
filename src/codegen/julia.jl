module JuliaExpr

using ..AST
using ..Options
using ..Comonicon: CommandException, CommandTerminate
using ExproniconLite

help_str(x; color = true) = sprint(print_cmd, x; context = :color => color)
# printing in expression
emit_help(x, ptr::Int = 1; color = true) = quote
    if !isnothing(findnext(isequal("-h"), ARGS, $ptr)) ||
       !isnothing(findnext(isequal("--help"), ARGS, $ptr))
        print($(help_str(x; color = color)))
        return 0
    end
end

function emit_error(cmd, msg::String; color::Bool = true)
    msg = "Error: $msg, use -h or --help to check more detailed help info"
    return quote
        printstyled($msg; color = :red, bold = true)
        println()
        print($(help_str(cmd; color = color)))
        println()
        return 1
    end
end

function emit_error(cmd, msg::Expr; color::Bool = true)
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
        print($(help_str(cmd; color = color)))
        println()
        return 1
    end
end

"""
    emit(cmd::Entry[, ptr::Int=1])

Emit `Expr` from a `Entry`.
"""
function emit(cmd::Entry, ptr::Int = 1)
    jlfn = JLFunction(;
        name = :command_main,
        args = [Expr(:kw, :(ARGS::Vector{String}), :ARGS)],
        body = quote
            $(emit_scan_version(cmd))
            $(emit_body(cmd.root, ptr))
        end,
    )
    return codegen_ast(jlfn)
end

function emit_scan_version(cmd::Entry)
    quote
        if "-V" in ARGS || "--version" in ARGS
            print($(cmd.version))
            return 0
        end
    end
end

function emit_body(cmd::NodeCommand, ptr::Int = 1)
    nargs_assert = quote
        if length(ARGS) < $ptr
            $(emit_error(
                cmd,
                "valid sub-commands for command $(cmd.name) are: $(join(keys(cmd.subcmds), ", "))",
            ))
        end
    end

    jl = JLIfElse()
    for (name, subcmd) in cmd.subcmds
        jl[:(ARGS[$ptr] == $name)] = emit_body(subcmd, ptr + 1)
    end
    jl.otherwise = emit_error(cmd, :("Error: unknown command $(ARGS[$ptr])"))
    return quote
        if length(ARGS) == $ptr && (ARGS[$(ptr)] == "-h" || ARGS[$(ptr)] == "--help")
            print($(help_str(cmd)))
            return 0
        end

        $nargs_assert
        $(codegen_ast(jl))
    end
end

function emit_body(cmd::LeafCommand, ptr::Int = 1)
    @gensym idx
    quote
        $(emit_help(cmd, ptr))

        $idx = findnext(isequal("--"), ARGS, $ptr)
        if isnothing($idx) # no dash
            $(emit_norm_body(cmd, ptr))
        else # dash
            $(emit_dash_body(cmd, idx, ptr))
        end
    end
end

function emit_dash_body(cmd::LeafCommand, idx::Symbol, ptr::Int = 1)
    @gensym token token_ptr args kwargs

    quote # parse option/flag
        $kwargs = []
        $token_ptr = $ptr
        while $token_ptr ≤ $idx - 1
            $token = ARGS[$token_ptr]
            if startswith($token, "-")
                $(emit_kwarg(cmd, token, kwargs, token_ptr))
            else
                $(emit_error(cmd, :("unknown command: $($token)")))
            end
            $token_ptr += 1
        end

        $args = ARGS[$idx+1:end]
        $(emit_leaf_call(cmd, args, kwargs))
    end
end

function emit_norm_body(cmd::LeafCommand, ptr::Int = 1)
    @gensym token_ptr args kwargs token

    quote
        $args = []
        $kwargs = []
        sizehint!($args, $(cmd.nrequire))
        $token_ptr = $ptr
        while $token_ptr ≤ length(ARGS)
            $token = ARGS[$token_ptr]
            if startswith($token, "-")
                $(emit_kwarg(cmd, token, kwargs, token_ptr))
            else # argument
                push!($args, $token)
            end
            $token_ptr += 1
        end

        $(emit_leaf_call(cmd, args, kwargs))
    end
end

function emit_leaf_call(cmd::LeafCommand, args::Symbol, kwargs::Symbol)
    @gensym nargs
    ret = quote
        $nargs = length($args)
    end

    if cmd.nrequire > 0
        push!(ret.args, quote
            if $(cmd.nrequire) > $nargs
                $(emit_error(cmd, "expect $(cmd.nrequire) positional arguments"))
            end
        end)
    end

    # check maximum number of arguments
    if isnothing(cmd.vararg)
        push!(
            ret.args,
            quote
                if $(length(cmd.args)) < $nargs
                    $(emit_error(cmd, "expect at most $(length(cmd.args)) positional arguments"))
                end
            end,
        )
    end

    call = Expr(:call, cmd.fn)
    if !isempty(cmd.flags) || !isempty(cmd.options)
        push!(call.args, Expr(:parameters, :($kwargs...)))
    end

    for (i, arg) in enumerate(cmd.args)
        arg.require || break
        push!(call.args, emit_parse_value(cmd, arg.type, :($args[$i])))
    end

    ifelse = JLIfElse()
    ifelse[:($nargs == $(cmd.nrequire))] = quote
        $(emit_exception_handle(cmd, call))
        return 0
    end

    for i in cmd.nrequire+1:length(cmd.args)
        call = copy(call)
        type = cmd.args[i].type
        push!(call.args, emit_parse_value(cmd, type, :($args[$i])))
        ifelse[:($nargs == $i)] = quote
            $(emit_exception_handle(cmd, call))
            return 0
        end
    end

    if isnothing(cmd.vararg)
        ifelse.otherwise = emit_error(cmd, "expect at most $(length(cmd.args)) positional arguments")
    else
        @gensym varargs
        call = copy(call)
        push!(call.args, :($varargs...))
        type = cmd.vararg.type
        if type === Any || type === String || type === AbstractString
            ifelse.otherwise = quote
                $varargs = $args[$(length(cmd.args))+1:end]
                $(emit_exception_handle(cmd, call))
                return 0
            end
        else
            ifelse.otherwise = quote
                $varargs = map($args[$(length(cmd.args) + 1):end]) do value
                    $(emit_parse_value(cmd, type, :value))
                end
                $(emit_exception_handle(cmd, call))
                return 0
            end
        end
    end

    push!(ret.args, codegen_ast(ifelse))
    return ret
end

function emit_exception_handle(cmd::LeafCommand, call, color::Bool = true)
    quote
        try
            $call
        catch e
            # NOTE:
            # terminate should return 0
            # other exception will return 1
            if e isa $CommandTerminate
                print("command exit")
                return 0
            elseif e isa $CommandException
                showerror(stdout, e)
                println()
                print($(help_str(cmd; color = color)))
                println()
                return e.exitcode
            else
                rethrow(e)
            end
        end
    end
end

function emit_kwarg(cmd::LeafCommand, token::Symbol, kwargs::Symbol, token_ptr)
    if isempty(cmd.flags) && isempty(cmd.options)
        return emit_error(cmd, :("do not have $($token)"))
    end

    @gensym sym key value

    ifelse = JLIfElse()
    # short flag
    ifelse[:(length($token) == 2)] = quote
        $key = $token[2:2]
        $(emit_short_flag(cmd, token, sym, key, value))
    end

    # long option/flag
    ifelse[:(startswith($token, "--"))] = quote
        $key = lstrip(split($token, '=')[1], '-')
        $(emit_long_option_or_flag(cmd, token, sym, key, value, token_ptr))
    end

    # short option
    ifelse.otherwise = quote
        $key = $token[2:2]
        $(emit_short_option(cmd, token, sym, key, value, token_ptr))
    end

    return quote
        $(codegen_ast(ifelse))
        push!($kwargs, $sym => $value)
    end
end

function emit_short_flag(cmd::LeafCommand, token::Symbol, sym::Symbol, key::Symbol, value::Symbol)
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
    ifelse.otherwise = emit_error(cmd, :("cannot find flag: $($token)"))
    return codegen_ast(ifelse)
end

function emit_short_option(
    cmd::LeafCommand,
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
                    _, $value = split($token, '=')
                elseif length($token) == 2 # read next
                    $token_ptr += 1
                    if $token_ptr > length(ARGS)
                        $(emit_error(option, "expect a value"))
                    end
                    $value = ARGS[$token_ptr]
                else # -o<value>
                    $value = $token[3:end]
                end
                $sym = $(QuoteNode(option.sym))
                $value = $(emit_parse_value(option, option.type, value))
            end
        end
    end
    ifelse.otherwise = emit_error(cmd, :("cannot find $($token)"))
    return codegen_ast(ifelse)
end

function emit_long_option_or_flag(
    cmd::LeafCommand,
    token::Symbol,
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
            $(emit_option(option, token, value, token_ptr))
        end
    end

    ifelse.otherwise = emit_error(cmd, :("cannot find $($token)"))
    return codegen_ast(ifelse)
end

function emit_parse_value(cmd, type, value)
    if type === Any || type === String || type === AbstractString
        return value
    else
        @gensym ret
        return quote
            $ret = tryparse($type, $value)
            if isnothing($ret)
                $(emit_error(cmd, "expect value of type: $(type)"))
            end
            $ret
        end
    end
end

function emit_option(option::Option, token::Symbol, value::Symbol, token_ptr::Symbol)
    return quote
        if occursin('=', $token)
            _, $value = split($token, '=')
        else # read next token
            $token_ptr += 1
            if $token_ptr > length(ARGS)
                $(emit_error(option, "expect a value"))
            end
            $value = ARGS[$token_ptr]
        end
        $value = $(emit_parse_value(option, option.type, value))
    end
end

end
