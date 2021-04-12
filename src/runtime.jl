module Runtime

using ..IR
export interpret

interpret(cmd::CLIEntry, ARGS::Vector{String}=ARGS) = interpret(stdout, cmd, ARGS)

function interpret(io::IO, cmd::CLIEntry, ARGS::Vector{String} = ARGS)::Int
    if "--version" in ARGS || "-V" in ARGS
        print(io, cmd.version)
        return 0
    end

    if "-h" in ARGS || "--help" in ARGS
        return interpret_help(io, cmd, ARGS)
    end

    return interpret_command(io, cmd, ARGS)
end

function interpret_help(io::IO, cmd::CLIEntry, ARGS::Vector{String}=ARGS)::Int
    current_cmd = cmd.root
    for each in ARGS
        if current_cmd isa LeafCommand # found a leaf node
            break
        elseif startswith(each, "-") # ignore all option/flag
            continue
        else
            if haskey(current_cmd.subcmds, each)
                current_cmd = current_cmd.subcmds[each]
            else
                return cmd_error(io, current_cmd, "invalid input $each")
            end
        end
    end
    # always print something the closest
    # help info instead of error
    print_cmd(io, current_cmd)
    return 0
end

function interpret_command(io::IO, cmd::CLIEntry, ARGS::Vector{String}=ARGS)::Int
    current_cmd = cmd.root; ptr = 1;
    while ptr ≤ length(ARGS)
        token = ARGS[ptr]
        if current_cmd isa NodeCommand
            if !haskey(current_cmd.subcmds, token)
                return cmd_error(io, current_cmd, "invalid input $token")
            end
            current_cmd = current_cmd.subcmds[token]
            ptr += 1
        elseif current_cmd isa LeafCommand
            break
        else
            return cmd_error(io, current_cmd,
                "invalid input $token, option/flags must be after leaf command")
        end
    end
    if current_cmd isa LeafCommand
        return interpret_leaf(io, current_cmd::LeafCommand, ptr, ARGS)
    end
    return cmd_error(io, current_cmd, "missing sub-command")
end

function interpret_leaf(io::IO, cmd::LeafCommand, ptr::Int, ARGS::Vector{String}=ARGS, token::String=ARGS[ptr])::Int
    for idx in ptr:length(ARGS)
        if ARGS[idx] == "--"
            return interpret_leaf_dash(io, cmd, ARGS[idx+1:end] #=args=#, ARGS[ptr:idx-1] #=kwargs=#)
        end
    end

    return interpret_leaf_norm(io, cmd, ptr, ARGS)
end

function interpret_leaf_dash(io::IO, cmd::LeafCommand, args::Vector{String}, kwargs::Vector{String})::Int
    assert_nargs(io, cmd, args) < 0 && return -1

    f_args = []
    for i in 1:length(args)
        if i ≤ length(cmd.args)
            arg = cmd.args[i]
        else
            arg = cmd.vararg
        end
        push!(f_args, convert_token(arg, args[i]))
    end

    ptr = 1; f_kwargs = []
    while ptr ≤ length(kwargs)
        ptr = interpret_option!(f_kwargs, io, cmd, ptr, kwargs, kwargs[ptr])
        ptr > 0 || return ptr
    end
    cmd.fn(f_args...; f_kwargs...)
    return 0
end

function interpret_leaf_norm(io::IO, cmd::LeafCommand, ptr::Int, ARGS::Vector{String})::Int
    ptr, karg, f_args, f_kwargs = ptr, 1, [], []
    while ptr ≤ length(ARGS)
        token = ARGS[ptr]
        if startswith(token, "-") # option/flag
            ptr = interpret_option!(f_kwargs, io, cmd, ptr, ARGS, token)
            ptr > 0 || return ptr
        else # argument
            karg = interpret_arg!(f_args, io, cmd, karg, token)
            karg > 0 || return karg
            ptr += 1
        end
    end

    assert_nargs(io, cmd, f_args) < 0 && return -1
    cmd.fn(f_args...; f_kwargs...)
    return 0
end

function interpret_option!(f_kwargs, io::IO, cmd::LeafCommand, ptr::Int, ARGS::Vector{String}, token::String=ARGS[ptr])::Int
    if occursin('=', token) # --option=<value>/-o=<value>
        return interpret_option_assign!(f_kwargs, io, cmd, ptr, ARGS, token)
    else
        return interpret_option_misc!(f_kwargs, io, cmd, ptr, ARGS, token)
    end
end

function interpret_arg!(f_args, io::IO, cmd::LeafCommand, k::Int, token::String)::Int
    if k ≤ length(cmd.args)
        arg = cmd.args[k]
    elseif !isnothing(cmd.vararg)
        arg = cmd.vararg
    else
        cmd_error(io, cmd, "too much arguments")
        return -1
    end
    push!(f_args, convert_token(arg, token))
    return k+1
end

function interpret_option_assign!(f_kwargs::Vector{Any}, io::IO, cmd::LeafCommand, ptr::Int, ARGS::Vector{String}, token::String=ARGS[ptr])::Int
    splitted = split(token, '=')
    if !(length(splitted) == 2)
        cmd_error(io, cmd, "expect --option=<value> or -o=<value>, got $token")
        return -1
    end
    name, value = splitted[1], String(splitted[2])
    
    if startswith(name, "--") || startswith(name, "-")
        name = lstrip(name, '-')
        if haskey(cmd.options, name)
            opt = cmd.options[name]
            value = convert_token(opt, value)
            push!(f_kwargs, opt.sym=>value)
        else
            cmd_error(io, cmd, "cannot find option $name")
            return -1
        end
    else
        cmd_error(io, cmd, "expect --option=<value> or -o=<value>, got $token")
        return -1
    end
    return ptr + 1
end

function interpret_option_misc!(f_kwargs::Vector{Any}, io::IO, cmd::LeafCommand, ptr::Int, ARGS::Vector{String}, token::String=ARGS[ptr])::Int
    # --option <value>/-o<value>/-o <value>
    # --flag/-f
    name = lstrip(token, '-')
    if startswith(token, "--") # --option <value>/--flag
        if haskey(cmd.options, name) # --option <value>
            opt = cmd.options[name]
            value = convert_token(opt, ARGS[ptr+1])
            push!(f_kwargs, opt.sym=>value)
            return ptr + 2
        elseif haskey(cmd.flags, name) # --flag
            push!(f_kwargs, cmd.flags[name].sym => true)
            return ptr + 1
        else
            cmd_error(io, cmd, "cannot find option/flag $name")
            return -1
        end
    elseif startswith(token, "-") # -o <value>/-f/-o<value>
        key = name[1:1]
        if haskey(cmd.options, key)
            opt = cmd.options[key]
            if length(name) == 1 # -o <value>
                value = ARGS[ptr+1]
                ret = ptr + 2
            else # -o<value>
                value = name[2:end]
                ret = ptr + 1
            end
            value = convert_token(opt, String(value))
            push!(f_kwargs, opt.sym => value)
            return ret
        elseif haskey(cmd.flags, key) # -f
            flg = cmd.flags[key]
            if length(name) != 1
                cmd_error(io, cmd, "expect -$key or --$(flg.name), got $token")
                return -1
            end
            push!(f_kwargs, flg.sym=>true)
            return ptr + 1
        else
            cmd_error(io, cmd, "cannot find option/flag $token")
            return -1
        end
    else
        cmd_error(io, cmd, "expect option or flag, got $token")
        return -1
    end
end

function convert_token(arg::Union{Argument, Option}, token::String)
    return if arg.type === Any || arg.type === String
        token
    else
        cmd_parse(arg.type, token)
    end
end

function assert_nargs(io::IO, cmd::LeafCommand, args)
    if cmd.nrequire > length(args)
        cmd_error(io, cmd, "expect at least $(cmd.nrequire) args, got $(length(args))")
        return -1
    end

    if isnothing(cmd.vararg) && length(cmd.args) < length(args)
        cmd_error(io, cmd, "expect at most $(length(cmd.args)) args, got $(length(args))")
        return -1
    end
    return 0
end

print_error(io::IO, xs...) = printstyled(io, "Error: ",  xs...; color=:light_red, bold=true)

function cmd_error(io::IO, cmd, msg)
    print_error(io, msg)
    print_cmd(io, cmd)
    return -1
end

cmd_parse(type, token::String) = parse(type, token)

end
