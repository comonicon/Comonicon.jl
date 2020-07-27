"""
    ASTCtx

AST code generation context.
"""
mutable struct ASTCtx
    ptr::Int
    help::Symbol
    version::Symbol
end

ASTCtx() = ASTCtx(1, gensym(:help), gensym(:version))

"""
    read_arg(ctx::ASTCtx)

Return the expression that read the next argument from ARGS.
"""
function read_arg(ctx::ASTCtx)
    ex = :(ARGS[$(ctx.ptr)])
    ctx.ptr += 1
    return ex
end

"""
    codegen(ctx, cmd)

Generate target code according to given context `ctx` from a command object `cmd`.
"""
function codegen end

"""
    codegen(cmd)

Generate Julia AST from given command object `cmd`. This will wrap
all the generated AST in a function `command_main`.
"""
function codegen(cmd::AbstractCommand)
    defs = Dict{Symbol,Any}()
    defs[:name] = :command_main
    defs[:args] = [Expr(:kw, :(ARGS::Vector{String}), :ARGS)]

    ctx = ASTCtx()
    defs[:body] = quote
        $(codegen_scan_glob(ctx))
        $(codegen(ctx, cmd))
    end
    return combinedef(defs)
end

function codegen(ctx::ASTCtx, cmd::LeafCommand)
    return quote
        $(codegen_help(ctx, cmd))
        $(codegen_body(ctx, cmd))
    end
end

function codegen(ctx::ASTCtx, cmd::NodeCommand)
    return quote
        $(codegen_help(ctx, cmd))
        $(codegen_body(ctx, cmd))
    end
end

function codegen(ctx::ASTCtx, cmd::EntryCommand)
    quote
        $(codegen_help(ctx, cmd.root, xprint_help(cmd)))
        $(codegen_version(ctx, cmd.root, xprint_version(cmd)))
        $(codegen_body(ctx, cmd.root))
    end
end

function codegen_scan_glob(ctx::ASTCtx)
    quote
        $(ctx.help) = -1
        $(ctx.version) = -1
        for i in 1:length(ARGS)
            x = ARGS[i]
            if x == "--help" || x == "-h"
                $(ctx.help) = i
                break
            end

            if x == "--version" || x == "-V"
                $(ctx.version) = i
                break
            end
        end
    end
end

function codegen_help(ctx::ASTCtx, cmd::NodeCommand, msg = xprint_help(cmd))
    return quote
        if $(ctx.help) == $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_help(ctx::ASTCtx, cmd::LeafCommand, msg = xprint_help(cmd))
    return quote
        if $(ctx.help) >= $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_version(ctx::ASTCtx, cmd::NodeCommand, msg)
    return quote
        if $(ctx.version) == $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_version(ctx::ASTCtx, cmd::LeafCommand, msg)
    return quote
        if $(ctx.version) >= $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_body(ctx::ASTCtx, cmd::NodeCommand)
    ex = Expr(:block)
    err_msg = "expect at least one argument for command $(cmd.name)"
    push!(ex.args, Expr(:if, :(length(ARGS) < $(ctx.ptr)), xerror(err_msg)))

    start = ctx.ptr
    for subcmd in cmd.subcmds
        push!(ex.args, Expr(:if, :($(read_arg(ctx)) == $(subcmd.name)), codegen(ctx, subcmd)))
        # reset ptr
        ctx.ptr = start
    end

    err_msg = :("Error: unknown command $(ARGS[$(ctx.ptr)])")
    push!(ex.args, xerror(err_msg))
    return ex
end

function codegen_body(ctx::ASTCtx, cmd::LeafCommand)
    parameters = gensym(:parameters)
    n_args = gensym(:n_args)
    nrequires = nrequired_args(cmd.args)
    ret = Expr(:block)
    validate_ex = Expr(:block)

    pushmaybe!(ret, codegen_params(ctx, parameters, cmd))

    if nrequires > 0
        err = xerror(
            :("command $($(cmd.name)) expect at least $($nrequires) arguments, got $($n_args)"),
        )
        push!(validate_ex.args, quote
            if $n_args < $nrequires
                $err
            end
        end)
    end

    # Error: too much arguments
    nmost = length(cmd.args)
    err = xerror(:("command $($(cmd.name)) expect at most $($nmost) arguments, got $($n_args)"))
    push!(validate_ex.args, quote
        if $n_args > $nmost
            $err
        end
    end)

    push!(ret.args, :($n_args = length(ARGS) - $(ctx.ptr - 1)))
    push!(ret.args, validate_ex)
    push!(ret.args, codegen_call(ctx, parameters, n_args, cmd))
    push!(ret.args, :(return 0))
    return ret
end

function codegen_params(ctx::ASTCtx, params::Symbol, cmd::LeafCommand)
    hasparameters(cmd) || return

    regexes, actions = [], []
    arg = gensym(:arg)
    it = gensym(:index)

    for opt in cmd.options
        push!(regexes, regex_option(opt))
        push!(regexes, regex_flag(opt))

        push!(actions, read_match(params, it, opt))
        push!(actions, read_forward(params, it, opt))

        if opt.short
            push!(regexes, regex_short_option(opt))
            push!(regexes, regex_short_flag(opt))

            push!(actions, read_match(params, it, opt))
            push!(actions, read_forward(params, it, opt))
        end
    end

    for flag in cmd.flags
        push!(regexes, regex_flag(flag))
        push!(actions, read_flag(params, it, flag))

        if flag.short
            push!(regexes, regex_short_flag(flag))
            push!(actions, read_flag(params, it, flag))
        end
    end

    return quote
        $params = []
        $it = $(ctx.ptr)
        while !isempty(ARGS) && $(ctx.ptr) <= $it <= length(ARGS)
            $arg = ARGS[$it]
            if startswith($arg, "-") # is a flag/option
                $(xmatch(regexes, actions, arg))
            else
                $it += 1
            end
        end
    end
end

function codegen_call(ctx::ASTCtx, params::Symbol, n_args::Symbol, cmd::LeafCommand)
    ex_call = Expr(:call, cmd.entry)
    if hasparameters(cmd)
        push!(ex_call.args, Expr(:parameters, :($params...)))
    end

    for (i, arg) in enumerate(cmd.args)
        if arg.require
            push!(ex_call.args, xparse_args(arg.type, ctx.ptr + i - 1))
        end
    end

    all_required(cmd) && return ex_call

    # handle optional arguments
    ex = Expr(:block)
    if cmd.nrequire >= 0
        push!(ex.args, Expr(:if, :($n_args == $(cmd.nrequire)), ex_call))
    end

    for i in cmd.nrequire+1:length(cmd.args)
        call_ex = copy(ex_call)
        expanded_call = push!(call_ex.args, xparse_args(cmd.args[i].type, ctx.ptr + i - 1))
        push!(ex.args, Expr(:if, :($n_args == $i), expanded_call))
    end
    return ex
end

function read_forward(parameters, it, option::Option)
    type = option.arg.type
    sym = QuoteNode(cmd_sym(option))

    function action(m)
        arg = xparse_args(type, :($it + 1))
        return quote
            $it < length(ARGS) || error("expect an argument")
            push!($parameters, $sym => $arg)
            deleteat!(ARGS, ($it, $it + 1))
            $it = $it - 1
        end
    end
end

function read_match(parameters, it, option::Option)
    type = option.arg.type
    sym = QuoteNode(cmd_sym(option))

    function action(m)
        arg = xparse(type, :(String($m[1])))
        return quote
            push!($parameters, $sym => $arg)
            deleteat!(ARGS, $it)
            $it = $it - 1
        end
    end
end

function read_flag(parameters, it, flag)
    sym = QuoteNode(cmd_sym(flag))
    function action(m)
        return quote
            push!($parameters, $sym => true)
            deleteat!(ARGS, $it)
            $it = $it - 1
        end
    end
end
