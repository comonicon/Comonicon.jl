module ZSHCompletions

using ..AST

const tab = " "

function emit(cmd::Entry)
    name = cmd.root.name
    "#compdef _$name $name \n" * emit("_", cmd.root, true)
end

function emit(prefix::String, cmd::NodeCommand, entry::Bool)
    lines = [
        "# These are set by _arguments",
        "local context state state_descr line",
        "typeset -A opt_args",
        "",
    ]

    args = basic_arguments(entry)
    hints = map(values(cmd.subcmds)) do x
        str = x.name * "\\:"
        str *= "'" * x.description.brief * "'"
    end

    hints = "((" * join(hints, " ") * "))"

    push!(args, "\"1: :$hints\"")
    push!(args, "\"*:: :->args\"")

    push!(lines, "_arguments -C \\")
    append!(lines, map(x -> tab * x * " \\", args))

    push!(lines, "")
    push!(lines, raw"case $state in")
    push!(lines, tab * "(args)")
    push!(lines, tab * tab * raw"case ${words[1]} in")

    commands = []
    for (_, each) in cmd.subcmds
        name = each.name
        push!(commands, name * ")")
        push!(commands, tab * prefix * cmd.name * "_" * name)
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
        function $prefix$(cmd.name)() {
        $body
        }
        """,
    )

    for (_, each) in cmd.subcmds
        push!(script, emit(prefix * cmd.name * "_", each, false))
    end

    return join(script, "\n\n")
end

function emit(prefix::String, cmd::LeafCommand, entry::Bool)
    lines = ["_arguments \\"]
    args = basic_arguments(entry)

    for (_, option) in cmd.options
        name = option.name
        doc = option.description.brief
        token = "--$name"
        if option.short
            token = "{-$(name[1]),--$name}"
        end
        push!(args, "$token'[$doc]'")
    end

    append!(lines, map(x -> tab * x * " \\", args))
    body = join(map(x -> tab * x, lines), "\n")

    return """
    function $prefix$(cmd.name)() {
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

end
