mutable struct TargetJL
    ptr::Int
    help::Symbol
    version::Symbol
    color::Bool
end

function emit(target::TargetJL, cmd::CLIEntry)
    fn = JLFunction(;
        name=:command_main,
        args=[Expr(:kw, :(ARGS::Vector{String}), :ARGS)],
        body=quote
            # let Julia throw InterruptException on SIGINT
            ccall(:jl_exit_on_sigint, Cvoid, (Cint,), 0)
            $(emit_version(target, cmd))
            if "--help" in ARGS || "-h" in ARGS
                $(emit_help(target, cmd.root))
            end

            if "--" in ARGS
                $(emit_dash_split(target, cmd.root))
            else
                $(emit(target, cmd.root))
            end
        end
    )
    return codegen_ast(fn)
end

function emit_dash_split(target::TargetJL, cmd)
end

function emit_version(target::TargetJL, cmd::CLIEntry)
    quote
        if "--version" in ARGS || "-V" in ARGS
            print($(cmd.version))
            return
        end
    end
end

function emit_help(target::TargetJL, cmd::LeafCommand)
    sprint(print_cmd, cmd; context=(:color=>target.color))

    quote
    end
end

function emit(cmd::NodeCommand)
end

function emit(cmd::LeafCommand)
end
