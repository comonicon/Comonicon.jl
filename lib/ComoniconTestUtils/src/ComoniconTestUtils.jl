module ComoniconTestUtils

export @test_args, @test_kwargs, rand_argument, rand_option, rand_flag,
    rand_node_command, rand_leaf_command, rand_command, rand_input

using Faker
using Random
using Configurations
using Comonicon.AST
using Configurations: Maybe

const args = Ref{Vector{Any}}([])
const kwargs = Ref{Vector{Any}}([])

function test_function(xs...; kw...)
    args[] = [xs...]
    kwargs[] = collect(Any, kw)
    return 1
end

macro test_args(ex)
    quote
        @test $ComoniconTestUtils.args[] == $(ex)
    end |> esc
end

macro test_kwargs(ex)
    quote
        @test $ComoniconTestUtils.kwargs[] == $ex
    end |> esc
end

function rand_name(len=6)
    a = rand('a':'z') # make sure first 1 are not -
    b = randstring(['a':'z'..., '-'], len-2)
    c = rand('a':'z') # make sure last 3 are not -
    return a * b * c
end

function rand_description()
    Faker.paragraph(number=4)
end

@option struct OptionParams
    name::Maybe{String} = nothing
    type=nothing
    short::Maybe{Bool}=nothing
    hint::Maybe{String}=nothing # if the value of hint is nothing, use Some(nothing)
    description::Maybe{String}=nothing
end

maybe(x, or) = isnothing(x) ? or : x

rand_option(;kw...) = rand_option(from_kwargs(OptionParams; kw...))

function rand_option(params::OptionParams)
    name = maybe(params.name, rand_name())
    type = maybe(params.type, rand([Int, Float32, Float64, String]))
    short = maybe(params.short, rand(Bool))
    hint = maybe(params.hint, rand([Faker.word(), nothing]))
    description = maybe(params.description, rand_description())

    # unpack Some(nothing)
    hint = hint isa Some ? hint.value : hint
    Option(;sym=Symbol(name), type, short, hint, description)
end

@option struct FlagParams
    name::Maybe{String} = nothing
    short::Maybe{Bool}=nothing
    description::Maybe{String}=nothing
end

rand_flag(;kw...) = rand_option(from_kwargs(FlagParams; kw...))

function rand_flag(params::FlagParams)
    name = maybe(params.name, rand_name())
    short = maybe(params.short, rand(Bool))
    description = maybe(params.description, rand_description())

    Flag(;sym=Symbol(name), short, description)
end

@option struct ArgParams
    name::Maybe{String} = nothing
    type=nothing
    require::Maybe{Bool}=nothing
    vararg::Maybe{Bool}=nothing
    default::Maybe{String} = nothing
    description::Maybe{String}=nothing
end

rand_argument(;kw...) = rand_argument(from_kwargs(ArgParams;kw...))

function rand_argument(params::ArgParams)
    name = maybe(params.name, rand_name())
    type = maybe(params.type, rand([Int, Float32, Float64, String]))
    require = maybe(params.require, rand(Bool))
    vararg = maybe(params.vararg, rand(Bool))
    default = params.require ? nothing :
            isnothing(params.default) ? Faker.word() : params.default
    description = maybe(params.description, rand_description())

    Argument(;name, type, vararg, require, default, description)
end

@option struct LeafParams
    name::Maybe{String} = nothing
    nrequire::Int = 2
    noptional::Int = 1
    vararg::Maybe{Bool} = nothing
    noptions::Int = 3
    nflags::Int = 3
    args::ArgParams = ArgParams() # don't generate vararg by default
    options::OptionParams = OptionParams()
    flags::FlagParams = FlagParams()
    description::Maybe{String}=nothing
end

rand_leaf_command(;kw...) = rand_leaf_command(from_kwargs(LeafParams; kw...))

function rand_leaf_command(params::LeafParams)
    name = maybe(params.name, rand_name())
    description = maybe(params.description, rand_description())
    options = Dict{String, Option}()
    flags = Dict{String, Flag}()
    for _ in 1:params.noptions
        opt = rand_option(params.options)
        options[opt.name] = opt
    end

    for _ in 1:params.nflags
        flg = rand_flag(params.flags)
        flags[flg.name] = flg
    end

    args = Argument[]
    for _ in 1:params.nrequire
        push!(args, rand_argument(;
            name=params.args.name,
            type=params.args.type,
            vararg=false,
            require=true,
            default=params.args.default,
            description=params.args.description,
        ))
    end

    for _ in 1:params.noptional
        push!(args, rand_argument(;
            name=params.args.name,
            type=params.args.type,
            vararg=false,
            require=false,
            default=nothing,
            description=params.args.description,
        ))
    end

    has_vararg = maybe(params.vararg, rand(Bool))

    if has_vararg
        vararg = rand_argument(;
            name=params.args.name,
            type=params.args.type,
            vararg=true,
            require=false,
            default=nothing,
            description=params.args.description,
        )
    else
        vararg = nothing
    end

    LeafCommand(;fn=test_function, name, args, vararg, options, flags, description)
end

@option struct NodeParams
    name::Maybe{String} = nothing
    nsubcmd::Int = 3
    max_depth::Int = 4 # maximum hierachy of node commands
    subcmd_contains_node::Bool = rand(Bool)
    description::Maybe{String}=nothing
    leaf::LeafParams = LeafParams()
end

rand_node_command(;kw...) = rand_node_command(from_kwargs(NodeParams; kw...))

function rand_node_command(params::NodeParams, depth::Int=0)
    name = maybe(params.name, rand_name())
    description = maybe(params.description, rand_description())
    subcmds = Dict{String, Any}()
    for _ in 1:params.nsubcmd
        # limit max depth
        if params.subcmd_contains_node && rand() < 0.5 && depth < params.max_depth
            cmd = rand_node_command(params, depth+1)
            subcmds[cmd.name] = cmd
        else
            cmd = rand_leaf_command(params.leaf)
            subcmds[cmd.name] = cmd
        end
    end

    NodeCommand(;name, subcmds, description)
end

@option struct CommandParams
    version::VersionNumber = v"1.2.3"
    has_node_command::Maybe{Bool} = nothing
    leaf::LeafParams = LeafParams()
    node::NodeParams = NodeParams()
end

rand_command(;kw...) = rand_command(from_kwargs(CommandParams;kw...))

function rand_command(params::CommandParams)
    has_node_command = maybe(params.has_node_command, rand(Bool))
    if has_node_command
        root = rand_node_command(params.node)    
    else
        root = rand_leaf_command(params.leaf)
    end

    return Entry(;root, version=params.version)
end

@option struct InputParams
    max_nvararg::Int = 5
    dash::Bool = false
    shuffle::Bool = true # shuffle inputs
    variable_nflags::Bool = true
    variable_noptions::Bool = true
end

rand_input(x;kw...) = rand_input(x, from_kwargs(InputParams; kw...))

rand_input(::Type{Any}, ::InputParams) = Faker.word()
rand_input(::Type{String}, ::InputParams) = randstring('a':'z', 5)
rand_input(::Type{Int}, ::InputParams) = Faker.random_int()
rand_input(::Type{T}, ::InputParams) where T = string(rand(T))
rand_input(entry::Entry, params::InputParams) = rand_input(entry.root, params)

function rand_input(entry::LeafCommand, params::InputParams)
    args = String[]
    for each in entry.args
        if each.require
            push!(args, rand_input(each.type, params))
        elseif rand() < 0.5
            push!(args, rand_input(each.type, params))
        end
    end
    
    if !isnothing(entry.vararg)
        for _ in 1:rand(1:params.max_nvararg)
            push!(args, rand_input(entry.vararg.type, params))
        end
    end

    nflags = params.variable_nflags ? rand(1:length(entry.flags)) : length(entry.flags)
    noptions = params.variable_noptions ? rand(1:length(entry.options)) : length(entry.options)

    flags = String[]
    for (_, flag) in shuffle(collect(entry.flags))[1:nflags]
        if flag.short && rand(Bool)
            push!(flags, "-" * first(flag.name))
        else
            push!(flags, "--" * flag.name)
        end
    end

    options = []
    for (_, option) in shuffle(collect(entry.options))[1:noptions]
        short = option.short && rand(Bool)
        name = short ? "-" * first(option.name) : "--" * option.name
        value = rand_input(option.type, params)

        if rand(Bool) # use_assign
            push!(options, (name * "=" * value, ))
        elseif short && rand(Bool) # use -o<value>
            push!(options, (name * value, ))
        else # use arg
            push!(options, (name, value))
        end
    end

    inputs = String[]

    while !isempty(args) || !isempty(flags) || !isempty(options)
        if rand(Bool) && !isempty(args)
            push!(inputs, popfirst!(args))
        elseif rand(Bool) && !isempty(flags)
            push!(inputs, pop!(flags))

        # at least push one of them
        elseif !isempty(options)
            push!(inputs, pop!(options)...)
        elseif !isempty(args)
            push!(inputs, popfirst!(args))
        else
            push!(inputs, pop!(flags))
        end
    end
    return inputs
end

function rand_input(cmd::NodeCommand, params::InputParams)
    _, next = rand(cmd.subcmds)
    inputs = rand_input(next, params)
    pushfirst!(inputs, next.name)
    return inputs
end

end
