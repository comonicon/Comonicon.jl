using Comonicon

@lazyload using Random @cast function random()
    isdefined(Main, :Random) && println("Random is loaded")
    isdefined(Main, :LinearAlgebra) && println("LinearAlgebra is loaded")
end

@lazyload using Random, LinearAlgebra @cast function both()
    isdefined(Main, :Random) && println("Random is loaded")
    isdefined(Main, :LinearAlgebra) && println("LinearAlgebra is loaded")
end

# this will throw an error
@cast function none()
    isdefined(Main, :Random) && println("Random is loaded")
    isdefined(Main, :LinearAlgebra) && println("LinearAlgebra is loaded")
end

@main

# You will see the following output if you run this script.
#
# shell> julia --project example/lazyload.jl random
# Random is loaded

# shell> julia --project example/lazyload.jl both
# Random is loaded
# LinearAlgebra is loaded

# shell> julia --project example/lazyload.jl none