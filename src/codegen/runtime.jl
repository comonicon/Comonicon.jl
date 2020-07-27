struct RuntimeCtx
    version::Int
    help::Int
    ptr::Int
end

RuntimeCtx() = RuntimeCtx(-1, -1, 1)

function read_arg(ctx::RuntimeCtx, args)
    x = args[ctx.ptr]
    ctx.ptr += 1
    return x
end

function exec(ctx::RuntimeCtx, cmd::NodeCommand, args::Vector{String})
    if length(args) < ctx.ptr
        error("expect at least one argument for command $(cmd.name)")
    end

    start = ctx.ptr
    for subcmd in cmd.subcmds
        if read_arg(ctx, args) == subcmd.name
            return exec(ctx, subcmd, args)
        end
        # reset ptr
        ctx.ptr = start
    end

    error("Error: unknown command $(ARGS[ctx.ptr])")
end

function exec(ctx::RuntimeCtx, cmd::LeafCommand, ARGS::Vector{String})
    if hasparameters(cmd)
        parameters = []
        index = ctx.ptr
        while !isempty(ARGS) && ctx.ptr <= index <= length(ARGS)
            startswith(each, "-") || continue
            arg = ARGS[index]

            for flag in cmd.flags
                long_name = "--" * flag.name
                if startswith(each, long_name)
                    if length(each) == length(long_name)
                        index < length(ARGS) || error("expect an argument")
                        push!(parameters, cmd_sym(flag) => arg)
                        deleteat!(ARGS, (index, index + 1))
                        index = index - 1
                    else
                        
                    end
                elseif flag.short && startswith(each, "-" * short_name(flag))
                end
            end

            for option in cmd.options
            end
        end
    end
end

function scan_glob!(ctx, args)
    for i in 1:length(args)
        x = args[i]
        if x == "--help" || x == "-h"
            $(ctx.help) = i
            break
        end

        if x == "--version" || x == "-V"
            $(ctx.version) = i
            break
        end
    end
    return ctx
end

function print_help(ctx::ASTCtx, cmd::NodeCommand)
    if ctx.help == ctx.ptr
        print_cmd(cmd)
        return 0
    end
end

function print_help(ctx::ASTCtx, cmd::LeafCommand)
    if ctx.help >= ctx.ptr
        print_cmd(cmd)
        return 0
    end
end

function print_version(ctx::ASTCtx, cmd::NodeCommand, msg)
    if ctx.version == ctx.ptr
        println(msg)
        return 0
    end
end

function print_version(ctx::ASTCtx, cmd::LeafCommand, msg)
    if ctx.version >= ctx.ptr
        println(msg)
        return 0
    end
end
