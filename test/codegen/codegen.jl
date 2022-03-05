using Test

@testset "JuliaExpr.emit" begin
    include("julia/node.jl")
    include("julia/arg.jl")
    include("julia/dash.jl")
    include("julia/optional.jl")
    include("julia/options.jl")
    include("julia/vararg.jl")
    include("julia/exception.jl")
    include("julia/plugin.jl")
end

@testset "ZSHCompletions.emit" begin
    include("zsh/zsh.jl")
end

@testset "BashCompletions.emit" begin
    include("bash.jl")
end
