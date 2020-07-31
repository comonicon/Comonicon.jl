const tab = " "^4

struct ZSHCompletionCtx end

function codegen(ctx::ZSHCompletionCtx, cmd::EntryCommand)
    name = cmd_name(cmd)
    "#compdef _$name $name \n" * codegen(ctx, "_", cmd.root, true)
end

function codegen(ctx::ZSHCompletionCtx, prefix::String, cmd::NodeCommand, entry::Bool)
    lines = ["local line", ""]

    args = basic_arguments(entry)

    push!(args, "1: :$(actions(cmd.subcmds))")
    push!(args, "*:: :->args")

    push!(lines, "_arguments -C \\")
    args = map(x -> "\"$x\"", args)
    append!(lines, map(x -> tab * x * " \\", args))

    push!(lines, "")
    push!(lines, raw"case $line[1] in")
    for each in cmd.subcmds
        name = cmd_name(each)
        push!(lines, string(tab, name, ")", prefix * cmd_name(cmd) * "_" * name))
        push!(lines, tab * ";;")
    end
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
        push!(args, "--$name[$doc]")

        if each.short
            push!(args, "-$(short_name(each))[$doc]")
        end
    end

    args = map(x -> "\"$x\"", args)
    append!(lines, map(x -> tab * x * " \\", args))
    body = join(map(x -> tab * x, lines), "\n")

    return """
    function $prefix$(cmd_name(cmd))() {
    $body
    }
    """
end

function basic_arguments(entry)
    args = ["-h[show help information]", "--help[show help information]"]

    if entry
        push!(args, "-V[show version information]")
        push!(args, "--version[show version information]")
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
