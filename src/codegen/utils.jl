help_str(x; color = true) = sprint(print_cmd, x; context = :color => color)

# printing in expression
xprint_help(x; color = true) = :(print($(help_str(x; color = color))))
xprint_version(cmd::EntryCommand; color = true) =
    :(println($(sprint(show, cmd; context = :color => color))))

"""
    xerror(msg)

Create an expression that contains error message, automatically merge
interpolation expressions.
"""
function xerror(msg::String)
    msg = "Error: $msg, use -h or --help to check more detailed help info"
    return :(error($msg))
end

function xerror(msg::Expr)
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
    return :(error($ex))
end

hasparameters(cmd::LeafCommand) = (!isempty(cmd.flags)) || (!isempty(cmd.options))

# regexes
short_name(x) = string(first(cmd_name(x)))

regex_flag(x) = Regex("^--$(cmd_name(x))\$")
regex_short_flag(x) = Regex("^-$(short_name(x))\$")

regex_option(x) = Regex("^--$(cmd_name(x))=(.*)")
regex_short_option(x) = Regex("^-$(short_name(x))(.*)")

xparse_args(type, index) = xparse(type, :(ARGS[$index]))

function xparse(type, str)
    if type in [Any, String, AbstractString]
        return :($str)
    else
        return :(convert($type, Meta.parse($str)))
    end
end

"""
    xmatch(regexes, actions, str[, st = 1])

Generate a long ifelse expression that acts like a pattern
matching expression that match given regex list and do the
corresponding actions.
"""
function xmatch(regexes, actions, str, st = 1)
    if st <= length(regexes)
        m = gensym(:m)
        regex, action = regexes[st], actions[st]

        return quote
            $m = match($regex, $str)
            if $m === nothing
                $(xmatch(regexes, actions, str, st + 1))
            else
                $(action(m))
            end
        end
    else
        return xerror(:("unknown option: $($str)"))
    end
end

function all_required(args::Vector)
    return all(args) do x
        x.require == true
    end
end

all_required(cmd::LeafCommand) = all_required(cmd.args)

function nrequired_args(args::Vector)
    return count(args) do x
        x.require == true
    end
end

"""
    rm_lineinfo(ex)

Remove `LineNumberNode` in a given expression
"""
function rm_lineinfo(ex)
    if ex isa Expr
        args = []
        for each in ex.args
            if !(each isa LineNumberNode)
                push!(args, rm_lineinfo(each))
            end
        end
        return Expr(ex.head, args...)
    else
        return ex
    end
end

"""
    prettify(ex)

Prettify given expression, remove all `LineNumberNode` and
extra code blocks.
"""
prettify(x) = x

function prettify(ex::Expr)
    ex = rm_lineinfo(ex)
    ex.head === :block || return Expr(ex.head, map(prettify, ex.args)...)

    if any(ex.args) do x
        x isa Expr && x.head === :block
    end

        return prettify(eat_blocks(ex))
    end
    return Expr(ex.head, map(prettify, ex.args)...)
end

function eat_blocks(ex::Expr)
    ex.head === :block || return Expr(ex.head, map(prettify, ex.args)...)
    args = []
    for stmt in ex.args
        if stmt isa Expr && stmt.head === :block
            for each in stmt.args
                push!(args, prettify(each))
            end
        else
            push!(args, prettify(stmt))
        end
    end
    return Expr(:block, args...)
end

"""
    push!(args, item)

Push an item to the expression or list. Do nothing
if the item is `nothing`.
"""
pushmaybe!(args, item) = push!(args, item)
pushmaybe!(args, ::Nothing) = args
pushmaybe!(ex::Expr, item) = push!(ex.args, item)
pushmaybe!(ex::Expr, ::Nothing) = ex
