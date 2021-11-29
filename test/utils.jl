function with_args(f, args::Vector{String}=String[])
    old = copy(ARGS)
    empty!(ARGS)
    append!(ARGS, args)
    ret = f()
    empty!(ARGS)
    append!(ARGS, old)
    return ret
end
