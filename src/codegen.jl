mutable struct CmdCtx
    ptr::Int
    help::Symbol
    version::Symbol
end

CmdCtx() = CmdCtx(1, gensym(:help), gensym(:version))

help_str(x) = sprint(print_cmd, x; context = :color => true)
print_help(x) = :(print($(help_str(x))))
print_version(cmd::EntryCommand) = :(println($(sprint(show, cmd; context = :color => true))))

hasparameters(cmd::LeafCommand) = (!isempty(cmd.flags)) || (!isempty(cmd.options))

function read_arg(ctx)
    ex = :(ARGS[$(ctx.ptr)])
    ctx.ptr += 1
    return ex
end

"""
    codegen(x)

Generates Julia AST and wrap them in the entry function `command_main`
for the given command object `x`.
"""
function codegen(x)
    ctx = CmdCtx()
    defs = Dict{Symbol,Any}()
    defs[:name] = :command_main
    defs[:args] = [Expr(:kw, :(ARGS::Vector{String}), :ARGS)]
    defs[:body] = codegen(ctx, x)
    return combinedef(defs)
end

function print_error(cmd, msg)
    quote
        printstyled("Error: "; color = :red, bold = true)
        printstyled($msg; color = :red)
        println()
        $(print_help(cmd))
        return 1
    end
end

function codegen(ctx, cmd::LeafCommand)
    return quote
        $(codegen_help(ctx, cmd))
        $(codegen_body(ctx, cmd))
    end
end

function codegen(ctx, cmd::NodeCommand)
    return quote
        $(codegen_help(ctx, cmd))
        $(codegen_body(ctx, cmd))
    end
end

function codegen(ctx, cmd::EntryCommand)
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

        $(codegen_help(ctx, cmd.root, print_help(cmd)))
        $(codegen_version(ctx, cmd.root, print_version(cmd)))
        $(codegen_body(ctx, cmd.root))
    end
end

function codegen_help(ctx, cmd::NodeCommand, msg = print_help(cmd))
    return quote
        if $(ctx.help) == $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_help(ctx, cmd::LeafCommand, msg = print_help(cmd))
    return quote
        if $(ctx.help) >= $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_version(ctx, cmd::NodeCommand, msg)
    return quote
        if $(ctx.help) == $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_version(ctx, cmd::LeafCommand, msg)
    return quote
        if $(ctx.help) >= $(ctx.ptr)
            $msg
            return 0
        end
    end
end

function codegen_body(ctx, cmd::LeafCommand)
    parameters = gensym(:parameters)
    ex = Expr(:block)

    if hasparameters(cmd)
        push!(ex.args, :($parameters = []))
    end

    if !isempty(cmd.flags) || !isempty(cmd.options)
        push!(ex.args, codegen_options_and_flags(ctx, parameters, cmd))
    end

    n_args = gensym(:n_args)
    push!(ex.args, :($n_args = length(ARGS) - $(ctx.ptr - 1)))

    # Error: not enough arguments
    nrequires = nrequired_args(cmd.args)

    if nrequires > 0
        err = print_error(
            cmd,
            :("command $($(cmd.name)) expect at least $($nrequires) arguments, got $($n_args)"),
        )
        push!(ex.args, quote
            if $n_args < $nrequires
                $err
            end
        end)
    end

    # Error: too much arguments
    nmost = length(cmd.args)
    err = print_error(
        cmd,
        :("command $($(cmd.name)) expect at most $($nmost) arguments, got $($n_args)"),
    )
    push!(ex.args, quote
        if $n_args > $nmost
            $err
        end
    end)

    ex_call = codegen_call(ctx, parameters, n_args, cmd)

    push!(ex.args, ex_call)
    push!(ex.args, :(return 0))
    return ex
end

function codegen_call(ctx, parameters, n_args, cmd::LeafCommand)
    ex_call = Expr(:call, cmd.entry)
    if hasparameters(cmd)
        push!(ex_call.args, Expr(:parameters, :($parameters...)))
    end

    for (i, arg) in enumerate(cmd.args)
        if arg.require
            push_arg!(ex_call, ctx, i, arg)
        end
    end

    if all_required(cmd)
        return ex_call
    end

    ex = Expr(:block)
    # expand optionals
    if cmd.nrequire >= 0
        push!(ex.args, Expr(:if, :($n_args == $(cmd.nrequire)), ex_call))
    end

    for i in cmd.nrequire+1:length(cmd.args)
        push!(ex.args, Expr(:if, :($n_args == $i), push_arg!(copy(ex_call), ctx, i, cmd.args[i])))
    end

    return ex
end

function push_arg!(ex, ctx, i, arg)
    if arg.type in [Any, String, AbstractString]
        push!(ex.args, :(ARGS[$(ctx.ptr+i-1)]))
    else
        push!(ex.args, :(convert($(arg.type), Meta.parse(ARGS[$(ctx.ptr + i - 1)]))))
    end
    return ex
end

function codegen_body(ctx, cmd::NodeCommand)
    ex = Expr(:block)
    err_msg = "expect at least one argument for command $(cmd.name)"
    push!(ex.args, Expr(:if, :(length(ARGS) < $(ctx.ptr)), print_error(cmd, err_msg)))

    start = ctx.ptr
    for subcmd in cmd.subcmds
        push!(ex.args, Expr(:if, :($(read_arg(ctx)) == $(subcmd.name)), codegen(ctx, subcmd)))
        # reset ptr
        ctx.ptr = start
    end

    err_msg = :("Error: unknown command $(ARGS[$(ctx.ptr)])")
    push!(ex.args, print_error(cmd, err_msg))
    return ex
end

function codegen_options_and_flags(ctx, parameters, cmd::LeafCommand)
    regexes = []
    actions = []
    arg = gensym(:arg)
    it = gensym(:it)

    for opt in cmd.options
        push!(regexes, Regex("^--$(cmd_name(opt))=(.*)"))
        push!(regexes, regex_flag(opt))

        push!(actions, read_match(parameters, it, opt))
        push!(actions, read_forward(parameters, it, opt))

        if opt.short
            push!(regexes, Regex("^-$(first(cmd_name(opt)))(.*)"))
            push!(regexes, short_regex_flag(opt))

            push!(actions, read_match(parameters, it, opt))
            push!(actions, read_forward(parameters, it, opt))
        end
    end

    for flag in cmd.flags
        push!(regexes, regex_flag(flag))

        push!(actions, read_flag(parameters, it, flag))

        if flag.short
            push!(regexes, short_regex_flag(flag))

            push!(actions, read_flag(parameters, it, flag))
        end
    end

    return quote
        $it = $(ctx.ptr)
        while !isempty(ARGS) && $(ctx.ptr) <= $it <= length(ARGS)
            $arg = ARGS[$it]

            if startswith($arg, "-")
                $(generate_match(regexes, actions, arg, it, cmd))
            else
                $it += 1
            end
        end
    end
end


generate_match(regexes, actions, arg, it, cmd) = generate_match(1, regexes, actions, arg, it, cmd)

function generate_match(i, regexes, actions, arg, it, cmd)
    if i <= length(regexes)
        m = gensym(:m)
        regex = regexes[i]
        action = actions[i]

        return quote
            $m = match($regex, $arg)
            $(Expr(
                :if,
                :($m === nothing),
                generate_match(i + 1, regexes, actions, arg, it, cmd),
                action(m),
            ))
        end
    else
        err_msg = :("unknown option $($arg)")
        return print_error(cmd, err_msg)
    end
end

function read_forward(parameters, it, option::Option)
    type = option.arg.type
    if type === Any
        push_ex = push_x(parameters, option, :(ARGS[$it+1]))
    else
        push_ex = push_x(parameters, option, :(convert($type, Meta.parse(ARGS[$it+1]))))
    end

    return m -> quote
        $it < length(ARGS) || error("expect an argument")
        $push_ex
        deleteat!(ARGS, ($it, $it + 1))
        $it = $it - 1
    end
end

function read_match(parameters, it, option::Option)
    type = option.arg.type
    if type === Any
        m -> quote
            $(push_x(parameters, option, :($m[1])))
            deleteat!(ARGS, $it)
            $it = $it - 1
        end
    else
        return m -> quote
            $(push_x(parameters, option, :(convert($type, Meta.parse($m[1])))))
            deleteat!(ARGS, $it)
            $it = $it - 1
        end
    end
end

function read_flag(parameters, it, flag)
    m -> quote
        $(push_x(parameters, flag, true))
        deleteat!(ARGS, $it)
        $it = $it - 1
    end
end

function push_x(parameters, x, item)
    :(push!($parameters, $(QuoteNode(Symbol(cmd_name(x)))) => $item))
end
