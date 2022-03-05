module BashCompletions

using ..AST
using ..Arg

tab(n::Int) = " "^n

indent(s::String, n::Int=1) = tab(4n) * s
function indent(lines::Vector, n::Int=1)
    indent.(lines, n)
end

function bash_function_name(tokens::Vector{String})
    return string("_", join(tokens, "_"), "_completion")
end

function emit(cmd::Entry)
    name = cmd.root.name
    comp_func = bash_function_name([name])
    return """
    $(emit(cmd.root, true))

    _$(name)_completion_entry() {
        $comp_func 1
    }

    complete -o nospace -F _$(name)_completion_entry $(name)
    """
end

function emit(cmd::NodeCommand, entry::Bool=false, prefix::Vector{String}=String[])
    subcmd_cases = ["case \"\$curr_word\" in"]
    for name in keys(cmd.subcmds)
        subcmd_func = bash_function_name([prefix..., cmd.name, name])
        push!(subcmd_cases, indent("$name) $subcmd_func \$((curr_word_idx+1));;"))
    end
    push!(subcmd_cases, indent("*)     ;;"))
    push!(subcmd_cases, "esac")

    # NOTE: NodeCommand always complete based on the last word
    available_cmds = join(keys(cmd.subcmds), " ")
    push!(available_cmds, "-h", "--help")
    if entry
        push!(available_cmds, "-V", "--version")
    end
    script = """
    $(bash_function_name([prefix..., cmd.name]))()
    {
        local curr_word_idx=\${1:-1}
        local curr_word="\${COMP_WORDS[curr_word_idx]}"
        if [[ "\$curr_word_idx" -eq "\$COMP_CWORD" ]]
        then
            COMPREPLY=(\$(compgen -W "$(available_cmds)" -- "\$curr_word"))
            return # return early if we're still completing the 'current' command
        fi

    $(join(indent(indent(subcmd_cases)), '\n'))
    }
    """

    for subcmd in values(cmd.subcmds)
        script *= "\n\n"
        script *= emit(subcmd, [prefix..., cmd.name])
    end
    return script
end

function emit(cmd::LeafCommand, entry::Bool=false, prefix::Vector{String}=String[])
    # last word doesn't match anything
    # specifically, but start with -
    # list all possible inputs
    dash_comp = String[]
    for flag in values(cmd.flags)
        push!(dash_comp, string("--", flag.name))
        flag.short && push!(dash_comp, string("-", flag.name))
    end
    push!(dash_comp, "-h", "--help")
    if entry
        push!(dash_comp, "-V", "--version")
    end

    # last word matches an option
    # complete the option argument
    option_comp = String[]
    skip_option = String[]
    for option in values(cmd.options)
        long_name = string("--", option.name)
        push!(option_comp, string(long_name, ")"))
        push!(option_comp, indent(emit_compgen(option.type, "last_word")))
        push!(option_comp, indent("return"))
        push!(option_comp, indent(";;"))
        push!(dash_comp, string(long_name, "="))

        push!(skip_option, string(long_name, ")"))
        push!(skip_option, indent("if [[ \"\${COMP_WORDS[i+1]}\" == \"=\" ]]"))
        push!(skip_option, indent("then"))
        push!(skip_option, indent("(( i+=2 ))", 2))
        push!(skip_option, indent("else"))
        push!(skip_option, indent("(( i+=1 ))", 2))
        push!(skip_option, indent("fi"))
        push!(skip_option, indent(";;"))

        if option.short
            short_name = string("-", first(option.name))
            push!(option_comp, string(short_name, ")"))
            push!(option_comp, indent(emit_compgen(option.type, "last_word")))
            push!(option_comp, indent("return"))
            push!(option_comp, indent(";;"))
            push!(dash_comp, short_name)
        end
    end

    # complete positional arguments
    args_comp = String[]
    for (k, arg) in enumerate(cmd.args)
        push!(args_comp, "$k)")
        push!(args_comp, indent(emit_compgen(arg.type, "last_word")))
        push!(args_comp, indent(";;"))
    end

    vararg_comp = String[]
    if isnothing(cmd.vararg)
        push!(vararg_comp, "*)")
        push!(vararg_comp, indent("COMPREPLY=()"))
        push!(vararg_comp, indent(";; # too much arguments just ignore"))
    else
        push!(vararg_comp, "*)")
        push!(vararg_comp, indent(emit_compgen(cmd.vararg.type, "last_word")))
        push!(vararg_comp, indent(";;"))
    end

    """
    $(bash_function_name([prefix..., cmd.name]))()
    {
        local curr_word_idx=\${1:-1}
        local last_word="\${COMP_WORDS[COMP_CWORD]}"
        local prev_word="\${COMP_WORDS[COMP_CWORD-1]}"

        if [[ "\$prev_word" == "=" ]]
        then
            prev_word="\${COMP_WORDS[COMP_CWORD-2]}"
        fi

        if [[ "\$last_word" == "=" ]]
        then
            last_word=""
        fi

        case "\$prev_word" in
    $(join(indent(option_comp, 2), '\n'))
        esac

        case "\$last_word" in
            -*) # complete flag or option name
                COMPREPLY=(\$(compgen -o nospace -W "$(join(dash_comp, " "))" -- "\$last_word"))
                ;;
            *) # complete arguments
                # count which argument to complete
                local narguments=0 i=\$curr_word_idx
                while [[ "\$i" -lt "\$COMP_CWORD" ]]; do
                    s="\${COMP_WORDS[i]}"
                    case "\$s" in
    $(join(indent(skip_option, 5), '\n'))
                        -*)
                            ;;
                        *)  (( narguments++ ))
                            ;;
                    esac
                    (( i++ ))
                done
                (( narguments++ ))
                case "\$narguments" in
    $(join(indent(args_comp, 4), '\n'))
    $(join(indent(vararg_comp, 4), '\n'))
                esac
                ;;
        esac
    }
    """
end

function emit_compgen(::Type{Arg.DirName}, word::String)
    "COMPREPLY=(\$(compgen -d -- \"\$$(word)\"))"
end

function emit_compgen(::Type{Arg.FileName}, word::String)
    "COMPREPLY=(\$(compgen -f -- \"\$$(word)\"))"
end

function emit_compgen(::Type{Arg.Prefix{name}}, word::String) where {name}
    prefix = string(name)
    "COMPREPLY=(\$(compgen -P \"$prefix\" -- \"\$$(word)\"))"
end

function emit_compgen(::Type{Arg.Suffix{name}}, word::String) where {name}
    suffix = string(name)
    "COMPREPLY=(\$(compgen -S \"$suffix\" -- \"\$$(word)\"))"
end

# if don't know how to complete, just go with default
function emit_compgen(::Type, word::String)
    "COMPREPLY=(\$(compgen -o default -- \"\$$(word)\"))"
end

end