const tab = " "^4

struct ZSHCompletionCtx end

function codegen(ctx::ZSHCompletionCtx, cmd::EntryCommand)
    name = cmd_name(cmd)
    "#compdef _$name $name \n" * codegen(ctx, "_", cmd.root, true)
end

function codegen(ctx::ZSHCompletionCtx, prefix::String, cmd::NodeCommand, entry::Bool)
    lines = [
        "# These are set by _arguments",
        "local context state state_descr line",
        "typeset -A opt_args",
        "",
    ]

    args = basic_arguments(entry)

    push!(args, "\"1: :$(actions(cmd.subcmds))\"")
    push!(args, "\"*:: :->args\"")

    push!(lines, "_arguments -C \\")
    append!(lines, map(x -> tab * x * " \\", args))

    push!(lines, "")
    push!(lines, raw"case $state in")
    push!(lines, tab * "(args)")
    push!(lines, tab * tab * raw"case ${words[1]} in")

    commands = []
    for each in cmd.subcmds
        name = cmd_name(each)
        push!(commands, name * ")")
        push!(commands, tab * prefix * cmd_name(cmd) * "_" * name)
        push!(commands, ";;")
    end
    append!(lines, map(x -> tab^3 * x, commands))
    push!(lines, tab^2 * "esac")
    push!(lines, "esac")

    body = join(map(x -> tab * x, lines), "\n")

    script = []
    push!(
        script,
        """
function $prefix$(cmd_name(cmd))() {
$body
}
""",
    )

    for each in cmd.subcmds
        push!(script, codegen(ctx, prefix * cmd_name(cmd) * "_", each, false))
    end

    return join(script, "\n\n")
end

function codegen(ctx::ZSHCompletionCtx, prefix::String, cmd::LeafCommand, entry::Bool)
    lines = ["_arguments \\"]
    args = basic_arguments(entry)

    for (i, each) in enumerate(cmd.options)
        name = cmd_name(each)
        doc = cmd_doc(each).first
        token = "--$name"
        if each.short
            token = "{-$(short_name(each)),--$name}"
        end
        push!(args, "$token'[$doc]'")
    end

    append!(lines, map(x -> tab * x * " \\", args))
    body = join(map(x -> tab * x, lines), "\n")

    return """
    function $prefix$(cmd_name(cmd))() {
    $body
    }
    """
end

function basic_arguments(entry)
    args = ["'(- 1 *)'{-h,--help}'[show help information]'"]

    if entry
        push!(args, "'(- 1 *)'{-V,--version}'[show version information]'")
    end
    return args
end

function actions(args)
    hints = map(args) do x
        str = cmd_name(x) * "\\:"
        str *= "'" * cmd_doc(x).first * "'"
    end

    return "((" * join(hints, " ") * "))"
end
